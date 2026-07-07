from reportlab.lib.pagesizes import A4
from reportlab.platypus import SimpleDocTemplate, Table, TableStyle, Paragraph, Spacer
from reportlab.lib.styles import getSampleStyleSheet
from reportlab.lib import colors
from openpyxl import Workbook
from io import BytesIO
from typing import List
from app.models.animal import Animal
from app.models.milk_record import MilkRecord

def generate_herd_pdf(animals: List[Animal]) -> BytesIO:
    buffer = BytesIO()
    doc = SimpleDocTemplate(buffer, pagesize=A4)
    elements = []
    styles = getSampleStyleSheet()

    # Title
    elements.append(Paragraph("IFMS Herd Registry Report", styles['Title']))
    elements.append(Spacer(1, 12))

    # Data
    data = [["Tag ID", "Species", "Breed", "Status", "Sex"]]
    for a in animals:
        data.append([a.tag_id, a.species, a.breed or "N/A", a.current_reproductive_status, a.sex])

    # Table
    t = Table(data)
    t.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.forestgreen),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.whitesmoke),
        ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('BOTTOMPADDING', (0, 0), (-1, 0), 12),
        ('BACKGROUND', (0, 1), (-1, -1), colors.beige),
        ('GRID', (0, 0), (-1, -1), 1, colors.black)
    ]))

    elements.append(t)
    doc.build(elements)
    buffer.seek(0)
    return buffer

def generate_dairy_excel(records: List[MilkRecord]) -> BytesIO:
    buffer = BytesIO()
    wb = Workbook()
    ws = wb.active
    ws.title = 'Milk Production'

    # Write headers
    headers = ["Date", "Animal ID", "Session", "Quantity (L)", "Withdrawn"]
    ws.append(headers)

    # Write records
    for r in records:
        ws.append([
            r.record_date.isoformat() if hasattr(r.record_date, 'isoformat') else str(r.record_date),
            str(r.animal_id),
            r.milking_session,
            r.quantity_liters,
            "Yes" if r.is_withdrawn else "No"
        ])

    wb.save(buffer)
    buffer.seek(0)
    return buffer
