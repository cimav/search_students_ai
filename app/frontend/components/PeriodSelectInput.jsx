import React, { useState, useMemo, useRef, useEffect } from 'react'
import { X } from 'lucide-react' // Puedes usar HeroIcons o cualquier ícono SVG

const PeriodSelectInput = ({ value, onChange }) => {
    const [isOpen, setIsOpen] = useState(false)
    const panelRef = useRef()

    const periods = useMemo(() => {
        const result = []
        const start = 2003
        const end = new Date().getFullYear()
        for (let y = start; y <= end; y++) {
            result.push(`${y}-1`)
            result.push(`${y}-2`)
        }
        return result
    }, [])

    const handleSelect = (period) => {
        onChange?.(period)
        setIsOpen(false)
    }

    const clearSelection = () => {
        onChange?.(null)
        setIsOpen(false)
    }

    useEffect(() => {
        const handleClickOutside = (e) => {
            if (panelRef.current && !panelRef.current.contains(e.target)) {
                setIsOpen(false)
            }
        }
        document.addEventListener('mousedown', handleClickOutside)
        return () => document.removeEventListener('mousedown', handleClickOutside)
    }, [])

    return (
        <div className="relative inline-block w-32" ref={panelRef}>
            {/* Input + botón de limpiar */}
            <div className="relative">
                <input
                    type="text"
                    readOnly
                    value={value || ''}
                    placeholder="Periodo"
                    onClick={() => setIsOpen(!isOpen)}
                    className="w-full border rounded px-2 py-1 text-sm text-center pr-7 cursor-pointer bg-white"
                />
                {value && (
                    <button
                        onClick={clearSelection}
                        className="absolute right-1 top-1/2 -translate-y-1/2 text-gray-400 hover:text-red-500"
                        title="Limpiar selección"
                    >
                        <X size={14} />
                    </button>
                )}
            </div>

            {/* Panel desplegable */}
            {isOpen && (
                <div className="absolute z-50 mt-2 w-[32rem] bg-white border rounded shadow-lg max-h-[28rem] overflow-y-auto p-4">
                    <div className="grid grid-cols-6 gap-2">
                        {periods.map((period) => (
                            <button
                                key={period}
                                onClick={() => handleSelect(period)}
                                className="text-sm px-2 py-1 rounded border hover:bg-blue-100 transition border-gray-300"
                            >
                                {period}
                            </button>
                        ))}
                    </div>
                </div>
            )}
        </div>
    )
}

export default PeriodSelectInput
