
import { serverSupabaseClient, serverSupabaseUser } from '#supabase/server'


export default defineEventHandler(async (event) => {
    const config = useRuntimeConfig()
    const supabase = await serverSupabaseClient(event)

    // Get path parameters
    const { org, project, version, path } = event.context.params
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
    const { data: rpcData, error: orgError } = await supabase
        .rpc('get_endpoint_response_by_api_key', {
            p_api_key: apiKey,
            p_base_path: `${project}/api/${version}`,
            p_org_name: org,
            p_path: path
        })

    const orgData = rpcData?.[0] ?? {}
    const response_body = orgData.data
    const status_code = orgData.status
    const endpoint_id = orgData?.endpoint_id
    const headers = orgData?.headers
    const response_type = orgData?.response_type
    const api_key_id = orgData?.api_key_id
    const org_id = orgData?.org_id
    const project_id = orgData?.project_id

    // // 5. Get request body if present
    // if (event.method !== 'GET') {
    //     try {
    //         requestBody = await readBody(event)

    //         console.log(requestBody)

    //     } catch(error) {
    //         console.log('Error reading request body',error)
    //         // Ignore parsing errors
    //     }
    // }

    // 6. Log the request
    await supabase.rpc('log_api_request', {
        p_organization_id: org_id,
        p_project_id: project_id,
        p_endpoint_id: endpoint_id,
        p_api_key_id: api_key_id,
        p_method: method,
        p_path: path,
        p_status_code: status_code,
        p_request_headers: getHeaders(event),
        p_request_body: 'requestBody',
        p_response_body: response_body,
        p_ip_address: getHeader(event, 'x-forwarded-for') || getHeader(event, 'x-real-ip'),
        p_user_agent: getHeader(event, 'user-agent')
    })

    // 7. Set response headers
    setHeaders(event, {
        'Content-Type': `application/${response_type}`,
        ...(headers || {})
    })

    // console.log(response_type)

    // 8. Return response
    event.node.res.statusCode = parseInt(status_code, 10) || 500
    return response_body
})
