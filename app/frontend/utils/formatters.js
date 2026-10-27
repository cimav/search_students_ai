export function formatDate(raw) {
    if (!raw) return "—";

    // Las fechas llegan como "YYYY-MM-DD"; new Date() las toma como UTC y en México muestra el día anterior.
    const match = /^(\d{4})-(\d{2})-(\d{2})/.exec(raw);
    if (match) return `${match[3]}/${match[2]}/${match[1]}`;

    const date = new Date(raw);
    return date.toLocaleDateString("es-MX", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
    });
}
