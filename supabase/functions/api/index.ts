
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
}

// Initialize Supabase client
const supabase = useSupabaseClient()

async function validateApiKey(apiKey: string): Promise<{ valid: boolean, organizationId?: string, apiKeyId?: string }> {
  try {
    // Get API key details
    const { data: keyData, error: keyError } = await supabase
      .from('api_keys')
      .select(`
        id, 
        access_type,
        organization_id,
        api_key_projects(project_id)
      `)
      .eq('key', apiKey)
      .eq('active', true)
      .single()

    if (keyError || !keyData) {
      return { valid: false }
    }

    return {
      valid: true,
      organizationId: keyData.organization_id,
      apiKeyId: keyData.id
    }
  } catch (error) {
    console.error('Error validating API key:', error)
    return { valid: false }
  }
}

async function handleRequest(req: Request): Promise<Response> {
  try {
    // Handle CORS preflight
    if (req.method === 'OPTIONS') {
      return new Response(null, { headers: corsHeaders })
    }

    const url = new URL(req.url)
    const path = url.pathname
    const method = req.method
    const startTime = Date.now()

    // Get API key from header
    const apiKey = req.headers.get('x-api-key')
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: 'API key is required' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate API key
    const { valid, organizationId, apiKeyId } = await validateApiKey(apiKey)
    if (!valid || !organizationId || !apiKeyId) {
      return new Response(
        JSON.stringify({ error: 'Invalid API key' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Parse path components
    // Format: /<org>/<project>/api/<version>/<path>
    const pathParts = path.split('/').filter(Boolean)
    if (pathParts.length < 5) {
      return new Response(
        JSON.stringify({ error: 'Invalid API path' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Extract components from path
    const subdomain = pathParts[0]
    const apiName = pathParts[1]
    // Skip 'api' in the path
    const version = pathParts[3]
    const endpointPath = pathParts.slice(4).join('/')

    // Verify organization
    const { data: org, error: orgError } = await supabase
      .from('organizations')
      .select('id')
      .eq('id', organizationId)
      .eq('subdomain', subdomain)
      .single()

    if (orgError || !org) {
      return new Response(
        JSON.stringify({ error: 'Organization not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get project
    const { data: project, error: projectError } = await supabase
      .from('projects')
      .select('id')
      .eq('organization_id', organizationId)
      .eq('api_name', apiName)
      .eq('version', version)
      .single()

    if (projectError || !project) {
      return new Response(
        JSON.stringify({ error: 'API not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get endpoint configuration
    const { data: endpoint, error: endpointError } = await supabase
      .from('endpoints')
      .select('*')
      .eq('project_id', project.id)
      .eq('method', method)
      .eq('path', endpointPath)
      .eq('active', true)
      .single()

    if (endpointError || !endpoint) {
      console.log('Endpoint not found:', {
        project_id: project.id,
        method,
        path: endpointPath
      })
      return new Response(
        JSON.stringify({ error: 'Endpoint not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get request body if present
    let requestBody = {}
    if (req.body) {
      try {
        requestBody = await req.json()
      } catch {
        // Ignore parsing errors
      }
    }

    // Log the request
    const duration = Date.now() - startTime
    await supabase.rpc('log_api_request', {
      p_organization_id: organizationId,
      p_project_id: project.id,
      p_endpoint_id: endpoint.id,
      p_api_key_id: apiKeyId,
      p_method: method,
      p_path: endpointPath,
      p_status_code: endpoint.status_code,
      p_request_headers: Object.fromEntries(req.headers),
      p_request_body: requestBody,
      p_response_body: endpoint.response_body,
      p_ip_address: req.headers.get('x-forwarded-for') || req.headers.get('x-real-ip'),
      p_user_agent: req.headers.get('user-agent'),
      p_duration_ms: duration
    })

    // Return configured response
    const headers = {
      ...corsHeaders,
      'Content-Type': `application/${endpoint.response_type}`,
      ...(endpoint.headers || {})
    }

    return new Response(
      JSON.stringify(endpoint.response_body),
      {
        status: endpoint.status_code,
        headers
      }
    )
  } catch (error) {
    console.error('Error handling request:', error)
    return new Response(
      JSON.stringify({ error: 'Internal server error' }),
      { status: 500, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
}

Deno.serve(handleRequest)