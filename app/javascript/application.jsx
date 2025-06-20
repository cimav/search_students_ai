// app/javascript/application.js

import "../frontend/index.css"
import React from "react"
import { createRoot } from "react-dom/client"
import App from "../frontend/components/App"

const container = document.getElementById("main_view")
if (container) {
  createRoot(container).render(<App />)
}

//  return <div style={{ border: '3px dotted green' }}><h1 className="text-3xl text-blue-600">✅ React + Tailwind funcionando. Y esta es la "vista" de React</h1></div>
