import MessageForm from './components/MessageForm'
import MessageList from './components/MessageList'

const SPRING_API_URL = process.env.SPRING_API_URL || 'http://localhost:30081'

async function getSpringInfo() {
  try {
    const res = await fetch(`${SPRING_API_URL}/`, {
      cache: 'no-store',
      next: { revalidate: 0 }
    })
    if (!res.ok) throw new Error('Failed to fetch')
    return await res.json()
  } catch (e) {
    return null
  }
}

async function getMessages() {
  try {
    const res = await fetch(`${SPRING_API_URL}/messages`, {
      cache: 'no-store',
      next: { revalidate: 0 }
    })
    if (!res.ok) throw new Error('Failed to fetch')
    return await res.json()
  } catch (e) {
    return []
  }
}

export default async function Home() {
  const hostname = process.env.HOSTNAME || 'unknown'
  const springInfo = await getSpringInfo()
  const messages = await getMessages()

  return (
    <main style={{ padding: '2rem', fontFamily: 'system-ui', maxWidth: '800px', margin: '0 auto' }}>
      <h1>Kubernetes Practice Dashboard</h1>

      <section style={{ marginTop: '1.5rem', padding: '1rem', background: '#e3f2fd', borderRadius: '8px' }}>
        <h2 style={{ margin: '0 0 0.5rem 0' }}>Next.js Info</h2>
        <p><strong>Service:</strong> next-app</p>
        <p><strong>Hostname:</strong> {hostname}</p>
      </section>

      <section style={{ marginTop: '1.5rem', padding: '1rem', background: '#e8f5e9', borderRadius: '8px' }}>
        <h2 style={{ margin: '0 0 0.5rem 0' }}>Spring Boot API</h2>
        {springInfo ? (
          <>
            <p><strong>Message:</strong> {springInfo.message}</p>
            <p><strong>Hostname:</strong> {springInfo.hostname}</p>
            <p><strong>Database:</strong> {springInfo.database}</p>
          </>
        ) : (
          <p style={{ color: '#c62828' }}>Unable to connect to Spring API</p>
        )}
      </section>

      <section style={{ marginTop: '1.5rem', padding: '1rem', background: '#fff3e0', borderRadius: '8px' }}>
        <h2 style={{ margin: '0 0 0.5rem 0' }}>Create Message</h2>
        <MessageForm />
      </section>

      <section style={{ marginTop: '1.5rem', padding: '1rem', background: '#f3e5f5', borderRadius: '8px' }}>
        <h2 style={{ margin: '0 0 0.5rem 0' }}>Messages from PostgreSQL</h2>
        <MessageList initialMessages={messages} />
      </section>
    </main>
  )
}
