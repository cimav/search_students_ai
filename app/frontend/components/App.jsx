// app/frontend/components/App.jsx

import React, { useState, useEffect } from "react"
import StudentsTable from "./StudentsTable"
import PeriodSelectInput from './PeriodSelectInput'

// 🔽 Opciones de estado (status)
const statusOptions = [
    { value: 1, label: "Activo" },
    { value: 5, label: "Egresado no graduado" },
    { value: 2, label: "Graduado" },
    { value: 3, label: "Baja temporal" },
    { value: 4, label: "Baja definitiva" },
    { value: 0, label: "Registro Eliminado" }
]

// 🔽 Opciones de campus
const campusOptions = [
    { value: 1, label: "Chihuahua" },
    { value: 2, label: "Monterrey" },
    { value: 4, label: "Durango" }
]

export default function App() {

    const [studentQuery, setStudentQuery] = useState("")
    const [selectedPrograms, setSelectedPrograms] = useState([])
    const [selectedAreas, setSelectedAreas] = useState([])
    const [programOptions, setProgramOptions] = useState([])
    const [areaOptions, setAreaOptions] = useState([])
    const [advisorQuery, setAdvisorQuery] = useState("")
    const [selectedStatus, setSelectedStatus] = useState([])
    const [selectedCampus, setSelectedCampus] = useState([])
    const [periodStart, setPeriodStart] = useState(null)
    const [periodFinal, setPeriodFinal] = useState(null)
    const [loading, setLoading] = useState(false)
    /*const [totalFiltered, setTotalFiltered] = useState(0)
    const [totalAll, setTotalAll] = useState(0) */

    // Cargar opciones de programas y áreas al iniciar
    useEffect(() => {
        fetch("/api/filters")
            .then(res => res.json())
            .then(data => {
                setProgramOptions(data.programs)
                setAreaOptions(data.areas)
            })
            .catch(error => console.error("Error al cargar filtros:", error))
    }, [])

    return (
        <div className="flex flex-col h-full ">

            <header className="bg-white shadow z-10 sticky top-0 p-4 space-y-4">

                <div className="flex flex-wrap gap-2 items-start">
                    {/* Input: Buscar por nombre */}
                    <div className="flex flex-col">
                        <label htmlFor="student_input"
                               className="text-sm font-medium text-gray-500">Estudiante</label>
                        <input
                            id="student_input"
                            type="search"
                            value={studentQuery}
                            onChange={(e) => setStudentQuery(e.target.value)}
                            className="h-8 text-sm px-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-300  w-140"
                            placeholder="🔍 Nombre del estudiante"
                        />
                    </div>
                    {/* Input: Buscar por asesor */}
                    <div className="flex flex-col">
                        <label htmlFor="advisor_input" className="text-sm font-medium text-gray-500">Asesor, co-asesor o
                            asesor externo</label>
                        <input
                            id="advisor_input"
                            type="search"
                            value={advisorQuery}
                            onChange={(e) => setAdvisorQuery(e.target.value)}
                            className="h-8 text-sm px-2 border border-gray-300 rounded-md focus:outline-none focus:ring-2 focus:ring-blue-300  w-140"
                            placeholder="🔍 Nombre del asesor"
                        />
                    </div>
                    {/* Selector de periodo */}
                    <div className="flex flex-col">
                        <label htmlFor="start_selector" className="text-sm font-medium text-gray-500">Inicio</label>
                        <PeriodSelectInput id='start_selector' value={periodStart} onChange={setPeriodStart}/>
                    </div>
                    <div className="flex flex-col">
                        <label htmlFor="final_selector" className="text-sm font-medium text-gray-500">Fin</label>
                        <PeriodSelectInput id='final_selector' value={periodFinal} onChange={setPeriodFinal}/>
                    </div>
                </div>

                <div className="flex flex-wrap gap-2 items-start mb-0">

                    {/* Select: Programas */}
                    <div className="flex flex-col">
                        <label htmlFor="selectedPrograms"
                               className="text-sm font-medium text-gray-500">Programas</label>
                        <select
                            id="selectedPrograms"
                            multiple
                            value={selectedPrograms}
                            onChange={(e) => {
                                const values = Array.from(e.target.selectedOptions, opt => opt.value)
                                setSelectedPrograms(values)
                            }}
                            className="border border-gray-300 rounded-md px-3 py-1 w-140 h-30 text-xs focus:outline-none focus:ring-2 focus:ring-blue-300"
                        >
                            {programOptions.map(program => (
                                <option key={program.id} value={program.id}>
                                    {`${program.prefix || ''} - ${program.name || ''}`}
                                </option>
                            ))}
                        </select>
                    </div>
                    {/* Select: Áreas */}
                    <div className="flex flex-col">
                        <label htmlFor="selectedAreas" className="text-sm font-medium text-gray-500">Areas</label>
                        <select
                            id="selectedAreas"
                            multiple
                            value={selectedAreas}
                            onChange={(e) => {
                                const values = Array.from(e.target.selectedOptions, opt => opt.value)
                                setSelectedAreas(values)
                            }}
                            className="border border-gray-300 rounded-md px-3 py-2 w-100 h-30 text-xs focus:outline-none focus:ring-2 focus:ring-blue-300"
                        >
                            {areaOptions.map(area => (
                                <option key={area.id} value={area.id}>
                                    {area.name}
                                </option>
                            ))}
                        </select>
                    </div>
                    {/* Select: Campus */}
                    <div className="flex flex-col">
                        <label htmlFor="selectedCampus" className="text-sm font-medium text-gray-500">Campus</label>
                        <select
                            id="selectedCampus"
                            multiple
                            value={selectedCampus}
                            onChange={(e) => {
                                const values = Array.from(e.target.selectedOptions, opt => Number(opt.value))
                                setSelectedCampus(values)
                            }}
                            className="border border-gray-300 rounded-md px-3 py-2 w-30 h-30 text-xs focus:outline-none focus:ring-2 focus:ring-blue-300"
                        >
                            {campusOptions.map(opt => (
                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                            ))}
                        </select>
                    </div>
                    {/* Select: Estatus */}
                    <div className="flex flex-col">
                        <label htmlFor="selectedStatus" className="text-sm font-medium text-gray-500">Status</label>
                        <select
                            id ="selectedStatus"
                            multiple
                            value={selectedStatus}
                            onChange={(e) => {
                                const values = Array.from(e.target.selectedOptions, opt => Number(opt.value))
                                setSelectedStatus(values)
                            }}
                            className="border border-gray-300 rounded-md px-3 py-2 w-50 h-30 text-xs focus:outline-none focus:ring-2 focus:ring-blue-300"
                        >
                            {statusOptions.map(opt => (
                                <option key={opt.value} value={opt.value}>{opt.label}</option>
                            ))}
                        </select>
                    </div>
                </div>

                {/* Barra de progreso siempre visible en gris */}
                <div className="absolute bottom-0 left-0 w-full h-1 bg-gray-200 rounded-b overflow-hidden">
                    {/* Barra azul animada solo cuando loading está activo */}
                    {loading && (
                        <div className="h-full bg-blue-500 animate-pulse" />
                    )}
                </div>
            </header>

            <main className="flex flex-col h-full">
                <StudentsTable
                    student={studentQuery}
                    programIds={selectedPrograms}
                    areaIds={selectedAreas}
                    advisor={advisorQuery}
                    statusList={selectedStatus}
                    campusList={selectedCampus}
                    termStart={periodStart}
                    termFinal={periodFinal}
                    setLoading={setLoading}
                />
            </main>

        </div>
    )
}


