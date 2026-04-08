const insertScript = (attrs: Record<string, string>): HTMLScriptElement => {
  const script = document.createElement('script')
  Object.entries(attrs).forEach(([key, value]) => script.setAttribute(key, value))
  document.head.appendChild(script)
  return script
}

const initSeline = (token: string): void => {
  insertScript({
    async: 'true',
    src: 'https://cdn.seline.so/seline.js',
    'data-token': token
  })
}

const initGA = (measurementId: string): void => {
  insertScript({
    async: 'true',
    src: `https://www.googletagmanager.com/gtag/js?id=${measurementId}`
  })

  // Inline snippet that initializes gtag after script loads
  const inlineScript = document.createElement('script')
  inlineScript.textContent = `
    window.dataLayer = window.dataLayer || [];
    function gtag(){dataLayer.push(arguments);}
    gtag('js', new Date());
    gtag('config', '${measurementId}');
  `
  document.head.appendChild(inlineScript)
}

export const initAnalytics = (): void => {
  if (typeof window === 'undefined') return

  const selineToken = import.meta.env.VITE_SELINE_TOKEN
  const gaId = import.meta.env.VITE_GA_ID

  if (selineToken) initSeline(selineToken)
  if (gaId) initGA(gaId)
}
