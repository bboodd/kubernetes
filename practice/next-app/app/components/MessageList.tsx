'use client'

import { useRouter } from 'next/navigation'

interface Message {
  id: number
  content: string
  hostname: string
  createdAt: string
}

export default function MessageList({ initialMessages }: { initialMessages: Message[] }) {
  const router = useRouter()

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr)
    return date.toLocaleString()
  }

  return (
    <div>
      <button
        onClick={() => router.refresh()}
        style={{
          marginBottom: '1rem',
          padding: '0.5rem 1rem',
          borderRadius: '4px',
          border: '1px solid #7b1fa2',
          background: 'transparent',
          color: '#7b1fa2',
          cursor: 'pointer'
        }}
      >
        Refresh
      </button>

      {initialMessages.length === 0 ? (
        <p>No messages yet</p>
      ) : (
        <ul style={{ listStyle: 'none', padding: 0, margin: 0 }}>
          {initialMessages.map((msg) => (
            <li
              key={msg.id}
              style={{
                padding: '0.75rem',
                marginBottom: '0.5rem',
                background: 'white',
                borderRadius: '4px',
                boxShadow: '0 1px 3px rgba(0,0,0,0.1)'
              }}
            >
              <p style={{ margin: '0 0 0.25rem 0', fontWeight: 'bold' }}>{msg.content}</p>
              <p style={{ margin: 0, fontSize: '0.85rem', color: '#666' }}>
                Pod: {msg.hostname} | {formatDate(msg.createdAt)}
              </p>
            </li>
          ))}
        </ul>
      )}
    </div>
  )
}
