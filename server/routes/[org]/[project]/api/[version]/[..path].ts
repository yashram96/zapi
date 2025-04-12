

export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig()
    const supabase = useSupabaseClient()

    // Get path parameters
    const { org, project, version } = event.context.params
    const path = '/' + (event.context.params.path || []).join('/')
    const method = event.method

    // Get API key from header
    const apiKey = getHeader(event, 'x-api-key')
    if (!apiKey) {
        return {
            error: true,
            message: 'Missing API Key in header',
            statusCode: 401
        }
    }

    // 1. Get organization by subdomain
    const { data: orgData, error: orgError } = await supabase
        .from('organizations')
        .select('id')
        .eq('subdomain', org)
        .single()

    if (orgError || !orgData) {
        return {
            error: true,
            message: 'Organization not found',
            statusCode: 404
        }
    }

    // 2. Validate API key
    const { data: apiKeyData, error: keyError } = await supabase
        .from('api_keys')
        .select('id, organization_id')
        .eq('key', apiKey)
        .eq('organization_id', orgData.id)
        .eq('active', true)
        .single()

    if (keyError || !apiKeyData) {
        return {
            error: true,
            message: 'Invalid API Key',
            statusCode: 403
        }
    }

    // 3. Get project
    const { data: projectData, error: projectError } = await supabase
        .from('projects')
        .select('id')
        .eq('organization_id', orgData.id)
        .eq('api_name', project)
        .eq('version', version)
        .single()

    if (projectError || !projectData) {
        return {
            error: true,
            message: 'Project not found',
            statusCode: 404
        }
    }

    // 4. Get endpoint
    const { data: endpoint, error: endpointError } = await supabase
        .from('endpoints')
        .select('*')
        .eq('project_id', projectData.id)
        .eq('method', method)
        .eq('path', path)
        .eq('active', true)
        .single()

    if (endpointError || !endpoint) {
        return {
            error: true,
            message: `No endpoint found for ${method} ${path}`,
            statusCode: 404
        }
    }

    // 5. Get request body if present
    let requestBody = {}
    if (event.method !== 'GET') {
        try {
            requestBody = await readBody(event)
        } catch {
            // Ignore parsing errors
        }
    }

    // 6. Log the request
    await supabase.rpc('log_api_request', {
        p_organization_id: orgData.id,
        p_project_id: projectData.id,
        p_endpoint_id: endpoint.id,
        p_api_key_id: apiKeyData.id,
        p_method: method,
        p_path: path,
        p_status_code: endpoint.status_code,
        p_request_headers: getHeaders(event),
        p_request_body: requestBody,
        p_response_body: endpoint.response_body,
        p_ip_address: getHeader(event, 'x-forwarded-for') || getHeader(event, 'x-real-ip'),
        p_user_agent: getHeader(event, 'user-agent')
    })

    // 7. Set response headers
    setHeaders(event, {
        'Content-Type': `application/${endpoint.response_type}`,
        ...(endpoint.headers || {})
    })

    // 8. Return response
    event.node.res.statusCode = endpoint.status_code
    return endpoint.response_body
})