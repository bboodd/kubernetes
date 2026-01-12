import { NextRequest, NextResponse } from 'next/server'

const SPRING_API_URL = process.env.SPRING_API_URL || 'http://localhost:30081'

export async function GET() {
  try {
    const res = await fetch(`${SPRING_API_URL}/messages`, {
      cache: 'no-store'
    })
    const data = await res.json()
    return NextResponse.json(data)
  } catch (e) {
    return NextResponse.json({ error: 'Failed to fetch messages' }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const res = await fetch(`${SPRING_API_URL}/messages`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    })
    const data = await res.json()
    return NextResponse.json(data)
  } catch (e) {
    return NextResponse.json({ error: 'Failed to create message' }, { status: 500 })
  }
}
