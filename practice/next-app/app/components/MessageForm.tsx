'use client'

import { useState } from 'react'
import { useRouter } from 'next/navigation'

export default function MessageForm() {
  const [content, setContent] = useState('')
  const [loading, setLoading] = useState(false)
  const [result, setResult] = useState<string | null>(null)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!content.trim()) return

    setLoading(true)
    setResult(null)

    try {
      const res = await fetch('/api/messages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ content })
      })

      if (!res.ok) throw new Error('Failed to create message')

      const data = await res.json()
      setResult(`Message created by: ${data.hostname}`)
      setContent('')
      router.refresh()
    } catch (e) {
      setResult('Failed to create message')
    } finally {
      setLoading(false)
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <div style={{ display: 'flex', gap: '0.5rem' }}>
        <input
          type="text"
          value={content}
          onChange={(e) => setContent(e.target.value)}
          placeholder="Enter message..."
          style={{
            flex: 1,
            padding: '0.5rem',
            borderRadius: '4px',
            border: '1px solid #ccc',
            fontSize: '1rem'
          }}
          disabled={loading}
        />
        <button
          type="submit"
          disabled={loading || !content.trim()}
          style={{
            padding: '0.5rem 1rem',
            borderRadius: '4px',
            border: 'none',
            background: loading ? '#ccc' : '#1976d2',
            color: 'white',
            cursor: loading ? 'not-allowed' : 'pointer',
            fontSize: '1rem'
          }}
        >
          {loading ? 'Sending...' : 'Send'}
        </button>
      </div>
      {result && (
        <p style={{ marginTop: '0.5rem', color: result.includes('Failed') ? '#c62828' : '#2e7d32' }}>
          {result}
        </p>
      )}
    </form>
  )
}
