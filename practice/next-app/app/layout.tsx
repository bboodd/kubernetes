export const metadata = {
  title: 'Next.js Kubernetes Practice',
  description: 'Next.js app running on Kubernetes',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
