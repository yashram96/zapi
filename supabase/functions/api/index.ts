import { createClient } from 'npm:@supabase/supabase-js@2.39.8'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-API-Key',
}

// Initialize Supabase client
const supabase = createClient(
  Deno.env.get('SUPABASE_URL') ?? '',
  Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
)

async function validateApiKey(apiKey: string, method: string, path: string): Promise<{ valid: boolean, projectId?: string }> {
  try {
    // Get API key details
    const { data: keyData, error: keyError } = await supabase
      .from('api_keys')
      .select('id, access_type, api_key_projects(project_id)')
      .eq('key', apiKey)
      .eq('active', true)
      .single()

    if (keyError || !keyData) {
      return { valid: false }
    }

    // Check access type for write operations
    if (method !== 'GET' && keyData.access_type !== 'write') {
      return { valid: false }
    }

    // Get project for this path
    const pathParts = path.split('/')
    if (pathParts.length < 4) return { valid: false }

    const orgSubdomain = pathParts[1]
    const apiName = pathParts[2]
    const version = pathParts[3]

    // Get organization ID from subdomain
    const { data: orgData } = await supabase
      .from('organizations')
      .select('id')
      .eq('subdomain', orgSubdomain)
      .single()

    if (!orgData) return { valid: false }

    // Get project ID
    const { data: projectData } = await supabase
      .from('projects')
      .select('id')
      .eq('organization_id', orgData.id)
      .eq('api_name', apiName)
      .eq('version', version)
      .single()

    if (!projectData) return { valid: false }

    // Check if API key has access to this project
    const hasAccess = keyData.api_key_projects.some(
      (p: any) => p.project_id === projectData.id
    )

    return {
      valid: hasAccess,
      projectId: hasAccess ? projectData.id : undefined
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

    // Get API key from header
    const apiKey = req.headers.get('x-api-key')
    if (!apiKey) {
      return new Response(
        JSON.stringify({ error: 'API key is required' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Validate API key
    const { valid, projectId } = await validateApiKey(apiKey, method, path)
    if (!valid || !projectId) {
      return new Response(
        JSON.stringify({ error: 'Invalid API key' }),
        { status: 401, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get endpoint configuration
    const endpointPath = path.split('/').slice(4).join('/')
    const { data: endpoint, error: endpointError } = await supabase
      .from('endpoints')
      .select('*')
      .eq('project_id', projectId)
      .eq('method', method)
      .eq('path', endpointPath)
      .eq('active', true)
      .single()

    if (endpointError || !endpoint) {
      return new Response(
        JSON.stringify({ error: 'Endpoint not found' }),
        { status: 404, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

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