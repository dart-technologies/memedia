export class ProviderError extends Error {
  code:string; status:number;
  constructor(code: string, status = 502) { super(code); this.code=code;this.status=status; }
}
export async function safeFetch(fetcher: typeof fetch, url: string | URL, init: RequestInit): Promise<Response> {
  try { return await fetcher(url,{...init,signal:AbortSignal.timeout(45000)}); }
  catch { throw new ProviderError('PROVIDER_NETWORK_OR_TIMEOUT'); }
}
