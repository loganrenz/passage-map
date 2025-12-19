/**
 * Helper to access Cloudflare environment bindings in Nitro
 * Tries multiple access patterns for compatibility with different Nitro/Cloudflare setups
 */
export function getCloudflareEnv(event: any): { [key: string]: unknown } {
  // Try multiple ways to access Cloudflare bindings
  // Pattern 1: event.context.cloudflare.env (standard Nitro/Cloudflare)
  if (event?.context?.cloudflare?.env) {
    return event.context.cloudflare.env
  }
  
  // Pattern 2: event.context.cloudflare (if bindings are directly on cloudflare)
  if (event?.context?.cloudflare && typeof event.context.cloudflare === 'object') {
    // Check if it has R2 bucket-like properties (get, put methods)
    const cf = event.context.cloudflare
    if ('PASSAGES_BUCKET' in cf || 'VESSEL_DATA_BUCKET' in cf || 'QUERIES_BUCKET' in cf) {
      return cf as { [key: string]: unknown }
    }
  }
  
  // Pattern 3: event.context.env (alternative pattern)
  if (event?.context?.env) {
    return event.context.env
  }
  
  // Pattern 4: event.env (if env is directly on event)
  if (event?.env) {
    return event.env
  }
  
  // Return empty object if no bindings found (will fall back to filesystem)
  return {}
}

