import { NextResponse } from 'next/server'

export async function GET() {
  return NextResponse.json({
    status: 'UP',
    hostname: process.env.HOSTNAME || 'unknown',
    service: 'next-app'
  })
}
