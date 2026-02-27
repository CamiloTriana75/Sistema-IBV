export default defineEventHandler((event) => {
  return { message: 'Test API working', timestamp: new Date().toISOString() }
})
