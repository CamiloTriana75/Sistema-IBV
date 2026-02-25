export const validators = {
  email: (email: string) => /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email),
  vin: (vin: string) => /^[A-Z0-9]{17}$/.test(vin),
  qrCode: (code: string) => code.length > 0,
  fileSize: (size: number, limitMB: number = 10) => size <= limitMB * 1024 * 1024,
}

export const utils = {
  formatBytes: (bytes: number) => {
    if (bytes === 0) return '0 Bytes'
    const k = 1024
    const sizes = ['Bytes', 'KB', 'MB', 'GB']
    const i = Math.floor(Math.log(bytes) / Math.log(k))
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
  },
}

export const formatters = {
  date: (date: string | Date) => new Date(date).toLocaleDateString('es-ES'),
  time: (date: string | Date) => new Date(date).toLocaleTimeString('es-ES'),
  dateTime: (date: string | Date) => new Date(date).toLocaleString('es-ES'),
}

export const downloadFile = (
  content: string | Blob,
  fileName: string,
  type: string = 'application/json'
) => {
  const blob = new Blob([content], { type })
  const url = window.URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = fileName
  link.click()
  window.URL.revokeObjectURL(url)
}
