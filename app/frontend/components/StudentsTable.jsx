// ✅ React Component: StudentsTable.jsx with TanStack Table and pagination
// app/frontend/components/StudentsTable.jsx

import React, {useEffect, useState} from "react"
import {
    useReactTable,
    getCoreRowModel,
    getPaginationRowModel,
    flexRender,
    createColumnHelper
} from "@tanstack/react-table"
import {formatDate} from "../utils/formatters";
import {ChevronsLeft, ChevronLeft, ChevronRight, ChevronsRight, FileDown} from "lucide-react"


const columnHelper = createColumnHelper()

export default function StudentsTable({student, programIds, areaIds, advisor, statusList, campusList, termStart, termFinal, setLoading}) {

    const [students, setStudents] = useState([])
    const [page, setPage] = useState(1)
    const [totalPages, setTotalPages] = useState(1)
    const [perPage, setPerPage] = useState(200)
    const [totalFiltered, setTotalFiltered] = useState(1)
    const [totalAll, setTotalAll] = useState(1)
    // const [selectedIds, setSelectedIds] = useState([])

    const fetchData = async () => {
        setLoading?.(true)  // activa la barra de carga si se pasó setLoading
        try {
            const searchParams = buildURLSearchParams()

            const res = await fetch(`/api/students/search?${searchParams.toString()}`)
            const data = await res.json()

            setStudents(data.students)
            setTotalPages(data.total_pages)
            setTotalFiltered(data.total_filtered)
            setTotalAll(data.total_all)
        } catch (err) {
            console.error("Error al consultar estudiantes:", err)
        } finally {
            setLoading?.(false)  // desactiva la barra de carga
        }
    }
    useEffect(() => {
        // useEffect es un hook que se ejecuta después de que el componente se renderiza
        // llamadas a APIs (fetch), manipulación del DOM, sincronización de datos.
        // código que quieres ejecutar cuando el componente se monta o cambian dependencias

        fetchData()

        if (page > totalPages && totalPages > 0) {
            setPage(totalPages)
        } else if (totalPages === 0) {
            setPage(1)
        }

        //setSelectedIds([]) // limiar cuando cambia de páagina

    }, [page, totalPages, student, programIds, areaIds, perPage, advisor, statusList, campusList, termStart, termFinal, setLoading])
    // lista de dependencias. React ejecutará el efecto (la función dentro de useEffect) cada vez que cambie alguno de esos valores.

    {/*
    const toggleRow = (id) => {
        setSelectedIds((prev) =>
            prev.includes(id) ? prev.filter((i) => i !== id) : [...prev, id]
        )
    }
    const toggleAllVisible = () => {
        const visibleIds = students.map((s) => s.id)
        const allSelected = visibleIds.every(id => selectedIds.includes(id))

        if (allSelected) {
            setSelectedIds(prev => prev.filter(id => !visibleIds.includes(id)))
        } else {
            setSelectedIds(prev => [...prev, ...visibleIds.filter(id => !prev.includes(id))])
        }
    }
    */}

    function buildURLSearchParams(){
        const params = new URLSearchParams()

        if (student) params.append("student", student)
        if (advisor) params.append("advisor", advisor)
        if (page) params.append("page", page)
        params.append("per_page", String(perPage))
        if (Array.isArray(areaIds)) {
            areaIds.forEach(id => params.append("area_ids[]", id))
        }
        if (Array.isArray(programIds)) {
            programIds.forEach(id => params.append("program_ids[]", id))
        }
        if (Array.isArray(statusList)) {
            statusList.forEach(id => params.append("status[]", id))
        }
        if (Array.isArray(campusList)) {
            campusList.forEach(id => params.append("campus[]", id))
        }
        if (termStart) params.append("term_start", termStart)
        if (termFinal) params.append("term_final", termFinal)

        return params
    }

    const columns = [
        columnHelper.accessor((row) => row.id, {
            id: "id",
            header: "Id",
            cell: info => (
                <div className="w-[60px]">
                    {info.getValue()}
                </div>
            ),
            size: 80, // preferencia interna de ancho
            minSize: 80,
            maxSize: 80
        }),
        columnHelper.accessor((row) => row.card, {
            id: "card",
            header: "Matrícula"
        }),
        columnHelper.accessor((row) => row.first_name, {
            id: "first_name",
            header: "Nombre"
        }),
        columnHelper.accessor((row) => row.paternal_name, {
            id: "paternal_name",
            header: "Apellido paterno"
        }),
        columnHelper.accessor((row) => row.maternal_name, {
            id: "maternal_name",
            header: "Apellido materno"
        }),
        columnHelper.accessor(
            (row) => formatDate(row.date_of_birth),
            {
                id: "date_of_birth",
                header: "Nacimiento"
            }
        ),
        columnHelper.accessor((row) => row.age || "—", {
            id: "age",
            header: "Edad"
        }),
        columnHelper.accessor((row) => row.gender || "—", {
            id: "gender",
            header: "Género"
        }),
        columnHelper.accessor((row) => row.program?.prefix || "—", {
            id: "program",
            header: "Programa"
        }),
        columnHelper.accessor((row) => row.studies_plan?.code || "—", {
            id: "studies_plan",
            header: "Plan Estudios"
        }),
        columnHelper.accessor((row) => row.campus_name || "—", {
            id: "campus",
            header: "Campus"
        }),
        columnHelper.accessor((row) => row.status_name || "—", {
            id: "status",
            header: "Estatus"
        }),
        columnHelper.accessor(
            (row) => formatDate(row.start_date),
            {
                id: "start_date",
                header: "Inicio"
            }
        ),
        columnHelper.accessor(
            (row) => formatDate(row.end_date),
            {
                id: "end_date",
                header: "Fin"
            }
        ),
        columnHelper.accessor(
            (row) => formatDate(row.graduation_date),
            {
                id: "graduation_date",
                header: "Graduación"
            }
        ),
        columnHelper.accessor(
            (row) => formatDate(row.inactive_date),
            {
                id: "inactive_date",
                header: "Inactive"
            }
        ),
        columnHelper.accessor(
            (row) => formatDate(row.definitive_inactive_date),
            {
                id: "definitive_inactive_date",
                header: "definitiva"
            }
        ),
        columnHelper.accessor((row) => row.area?.name || "—", {
            id: "area",
            header: "Area"
        }),
        columnHelper.accessor((row) => row.supervisor?.full_name || "—", {
            id: "supervisor",
            header: "Asesor"
        }),
        columnHelper.accessor((row) => row.co_supervisor?.full_name || "—", {
            id: "co_supervisor",
            header: "Co-asesor"
        }),
        columnHelper.accessor((row) => row.external_supervisor?.full_name || "—", {
            id: "external_supervisor",
            header: "Asesor externo"
        }),
        // columnHelper.accessor((row) => (row.term_students || []).map((ts) => ts.term?.code).join(", "), {
        columnHelper.accessor((row) => (row.all_term_codes) || "—", {
            id: "terms_codes",
            header: "Semestres",
            cell: info => (
                <div className="min-w-[280px] whitespace-normal break-words">
                    {info.getValue()}
                </div>
            )
        }),
        columnHelper.accessor((row) => (row.first_term_code) || "—", {
            id: "first_term_code",
            header: "Primer semestre"
        }),
        columnHelper.accessor((row) => row.these?.title || "—", {
            id: "these",
            header: "Tesis",
            cell: info => (
                <div className="min-w-[400px] whitespace-normal break-words">
                    {info.getValue()}
                </div>
            )
        }),
        columnHelper.accessor(
                (row) => formatDate(row.defence_date),
            {
                id: "defence_date",
                header: "Fecha Defensa"
            }
        ),
        columnHelper.accessor((row) => row.these?.status_name || "—", {
            id: "status_these",
            header: "Estatus Tesis"
        }),
        columnHelper.accessor((row) => row.email_cimav || "—", {
            id: "Email Cimav",
            header: "email_cimav"
        }),
        columnHelper.accessor((row) => row.email || "—", {
            id: "Email Personal",
            header: "email_personal"
        }),
        columnHelper.accessor((row) => row.country?.name || "—", {
            id: "country",
            header: "País"
        }),
        columnHelper.accessor((row) => row.state?.name || "—", {
            id: "state",
            header: "Estado"
        }),
        columnHelper.accessor((row) => row.city || "—", {
            id: "city",
            header: "Ciudad"
        }),
        columnHelper.accessor((row) => row.cvu || "—", {
            id: "cvu",
            header: "CVU"
        }),
        columnHelper.accessor((row) => row.curp || "—", {
            id: "CURP",
            header: "curp"
        }),
        columnHelper.accessor((row) => row.ife || "—", {
            id: "ine",
            header: "INE"
        }),
        columnHelper.accessor((row) => row.last_student_mobility?.institution || "—", {
            id: "last_mobility_institution",
            header: "Mobilidad Institución"
        }),
        columnHelper.accessor((row) => formatDate(row.last_student_mobility?.start_date), {
            id: "last_mobility_start_date",
            header: "Mobilidad Inicio"
        }),
        columnHelper.accessor((row) => formatDate(row.last_student_mobility?.end_date), {
            id: "last_mobility_end_date",
            header: "Mobilidad Fin"
        }),
        columnHelper.accessor((row) => row.last_student_mobility?.activities || "—", {
            id: "last_mobility_activities",
            header: "Mobilidad Actividades"
        }),

        columnHelper.accessor((row) => row.previous_institution?.name || "—", {
            id: "previous_institution",
            header: "Institución previa"
        }),
        columnHelper.accessor((row) => row.previous_degree_type || "—", {
            id: "previous_degree_type",
            header: "Tipo"
        }),
        columnHelper.accessor((row) => row.previous_degree_desc || "—", {
            id: "previous_degree_desc",
            header: "Descripción"
        }),
        columnHelper.accessor(
            (row) => formatDate(row.previous_degree_date),
            {
                id: "previous_degree_date",
                header: "Fecha"
            }
        ),

    ]

    function exportCSV() {
        const params = buildURLSearchParams()

        console.log(params.toString())

        window.open(`/api/students/export.csv?${params.toString()}`, "_blank")
    }

    const table = useReactTable({
        data: students,
        columns,
        getCoreRowModel: getCoreRowModel(),
        getPaginationRowModel: getPaginationRowModel(),
        manualPagination: true,
        pageCount: totalPages
    })

    const handleCopyToClipboard = () => {
        const rowsToCopy = students.filter((s) => selectedIds.includes(s.id))

        const text = rowsToCopy
            .map((s) => `${s.full_name} - ${s.email_cimav || s.email}`)
            .join("\n")

        navigator.clipboard.writeText(text).then(() => {
            alert(`${rowsToCopy.length} registros copiados al portapapeles.`)
        })
    }
    return (
        <div id="panel_table" className="relative max-h-[calc(100vh-20rem)] flex flex-col overflow-hidden rounded-lg">

            {/* Scroll horizontal y vertical envuelven tabla + paginación */}
            <div className="flex-1 overflow-x-auto">
                <div className="flex flex-col min-w-fit">

                    <table id="table_students" className="table-auto w-full rounded-lg shadow-sm text-xs ">
                        <thead className="bg-gray-200 border border-gray-300">
                        {table.getHeaderGroups().map((headerGroup) => (
                            <tr key={headerGroup.id}>
                                {/* <th>
                                    <input
                                        type="checkbox"
                                        checked={selectedIds.length > 0 && selectedIds.length === students.length}
                                        onChange={toggleAllVisible}
                                    />
                                </th> */}
                                {headerGroup.headers.map((header) => (
                                    <th
                                        key={header.id}
                                        className="sticky top-0 z-30 px-3 py-2 text-gray-800 uppercase tracking-wide text-xs font-medium border border-gray-300 bg-gray-200 min-w-[120px] whitespace-nowrap"
                                    >
                                        {flexRender(header.column.columnDef.header, header.getContext())}
                                    </th>
                                ))}
                            </tr>
                        ))}
                        </thead>
                        <tbody>
                        {table.getRowModel().rows.map((row) => (
                            <tr key={row.id} className="hover:bg-gray-50 transition-colors">
                                {/* <td>
                                    <input
                                        type="checkbox"
                                        checked={selectedIds.includes(student.id)}
                                        onChange={() => toggleRow(student.id)}
                                    />
                                </td> */}
                                {row.getVisibleCells().map((cell) => (
                                    <td
                                        key={cell.id}
                                        className={'whitespace-nowrap border border-gray-200 px-2 py-1 text-xs text-gray-700 min-w-[120px]'}
                                    >
                                        {flexRender(cell.column.columnDef.cell, cell.getContext())}
                                    </td>
                                ))}
                            </tr>
                        ))}
                        </tbody>
                    </table>

                </div>
            </div>

            <div id="bottom_panel"
                 className="sticky bottom-0 bg-white border-t border-gray-300 z-10 flex justify-between items-center px-4 py-2 text-sm">
                {/* Left: Pagination controls */}
                <div className="flex items-center gap-2">
                    <button onClick={() => setPage(1)} disabled={page === 1} title="Ir al inicio">
                        <ChevronsLeft size={18} className="text-gray-600 hover:text-black disabled:opacity-30"/>
                    </button>
                    <button onClick={() => setPage(p => Math.max(p - 1, 1))} disabled={page === 1} title="Anterior">
                        <ChevronLeft size={18} className="text-gray-600 hover:text-black disabled:opacity-30"/>
                    </button>
                    <span className="text-gray-600"> Página {page} / {totalPages} </span>
                    <button onClick={() => setPage(p => Math.min(p + 1, totalPages))} disabled={page === totalPages}
                            title="Siguiente">
                        <ChevronRight size={18} className="text-gray-600 hover:text-black disabled:opacity-30"/>
                    </button>
                    <button onClick={() => setPage(totalPages)} disabled={page === totalPages} title="Ir al final">
                        <ChevronsRight size={18} className="text-gray-600 hover:text-black disabled:opacity-30"/>
                    </button>
                </div>

                {/* Center: Totals */}
                <div className="text-gray-700">
                    Alumnos filtrados: {totalFiltered} / {totalAll}
                </div>

                {/* Right: Export button */}
                <div className="flex justify-between items-center gap-2">
                    {/* Botón copiar seleccionados */}
                    {/*
                    <button
                        disabled={selectedIds.length === 0}
                        onClick={handleCopyToClipboard}
                        className={`flex items-center gap-1 px-2 py-1 border rounded text-xs ${selectedIds.length === 0
                            ? 'bg-gray-100 text-gray-400 border-gray-300 cursor-not-allowed'
                            : 'hover:bg-gray-50 text-gray-700 border-gray-400 cursor-pointer'}`}>
                        📋 Copiar {selectedIds.length}
                    </button>
                    */}

                    {/* Botón exportar CSV */}
                    <button
                        title="Exportar alumnos filtrados a CSV"
                        onClick={exportCSV}
                        className="flex items-center gap-1 px-2 py-1 border border-gray-400 rounded hover:bg-sky-600 cursor-pointer text-xs text-gray-700 transition"
                    >
                        <FileDown size={16} className="text-gray-700"/>
                        <span>CSV</span>
                    </button>
                </div>

            </div>
            {/* "bottom_panel" */}

        </div>

    )
}
