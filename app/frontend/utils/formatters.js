export function formatDate(raw) {
    if (!raw) return "—";

    const date = new Date(raw);
    return date.toLocaleDateString("es-MX", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
    });
}
