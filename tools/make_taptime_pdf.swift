import Cocoa
import CoreText

let output = "/Users/vicorico/TapTime-Workplace-Attendance-Proposal.pdf"
let W: CGFloat = 595, H: CGFloat = 842
let navy = NSColor(calibratedRed: 0.055, green: 0.14, blue: 0.18, alpha: 1)
let teal = NSColor(calibratedRed: 0.04, green: 0.48, blue: 0.52, alpha: 1)
let aqua = NSColor(calibratedRed: 0.76, green: 0.92, blue: 0.90, alpha: 1)
let gold = NSColor(calibratedRed: 0.93, green: 0.66, blue: 0.24, alpha: 1)
let ink = NSColor(calibratedRed: 0.13, green: 0.17, blue: 0.19, alpha: 1)
let muted = NSColor(calibratedRed: 0.38, green: 0.45, blue: 0.47, alpha: 1)
let paper = NSColor(calibratedRed: 0.975, green: 0.985, blue: 0.983, alpha: 1)
let line = NSColor(calibratedRed: 0.84, green: 0.89, blue: 0.88, alpha: 1)

var box = CGRect(x: 0, y: 0, width: W, height: H)
guard let consumer = CGDataConsumer(url: URL(fileURLWithPath: output) as CFURL),
      let ctx = CGContext(consumer: consumer, mediaBox: &box, nil) else { exit(1) }

func fill(_ rect: CGRect, _ color: NSColor, radius: CGFloat = 0) {
    ctx.saveGState(); ctx.setFillColor(color.cgColor)
    if radius > 0 { ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil)); ctx.fillPath() }
    else { ctx.fill(rect) }
    ctx.restoreGState()
}

func drawImage(_ path: String, in rect: CGRect, radius: CGFloat = 0) {
    guard let image = NSImage(contentsOfFile: path),
          let cg = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return }
    ctx.saveGState()
    if radius > 0 {
        ctx.addPath(CGPath(roundedRect: rect, cornerWidth: radius, cornerHeight: radius, transform: nil))
        ctx.clip()
    }
    let imageRatio = CGFloat(cg.width) / CGFloat(cg.height)
    let rectRatio = rect.width / rect.height
    var drawRect = rect
    if imageRatio > rectRatio {
        let expandedW = rect.height * imageRatio
        drawRect = CGRect(x: rect.midX - expandedW / 2, y: rect.minY, width: expandedW, height: rect.height)
    } else {
        let expandedH = rect.width / imageRatio
        drawRect = CGRect(x: rect.minX, y: rect.midY - expandedH / 2, width: rect.width, height: expandedH)
    }
    ctx.draw(cg, in: drawRect)
    ctx.restoreGState()
}

@discardableResult
func text(_ value: String, x: CGFloat, top: CGFloat, width: CGFloat, size: CGFloat = 10.2,
          color: NSColor = ink, bold: Bool = false, spacing: CGFloat = 2.4,
          paragraph: CGFloat = 4, align: NSTextAlignment = .left) -> CGFloat {
    let style = NSMutableParagraphStyle(); style.lineSpacing = spacing; style.paragraphSpacing = paragraph; style.alignment = align
    let font = bold ? NSFont.systemFont(ofSize: size, weight: .semibold) : NSFont.systemFont(ofSize: size, weight: .regular)
    let a = NSAttributedString(string: value, attributes: [.font: font, .foregroundColor: color, .paragraphStyle: style])
    let fs = CTFramesetterCreateWithAttributedString(a)
    let suggested = CTFramesetterSuggestFrameSizeWithConstraints(fs, CFRange(location: 0, length: 0), nil, CGSize(width: width, height: 2000), nil)
    let height = ceil(suggested.height) + 2
    let rect = CGRect(x: x, y: top - height, width: width, height: height)
    let frame = CTFramesetterCreateFrame(fs, CFRange(location: 0, length: 0), CGPath(rect: rect, transform: nil), nil)
    ctx.textMatrix = .identity; CTFrameDraw(frame, ctx)
    return top - height
}

func beginPage(_ number: Int, _ section: String) {
    ctx.beginPDFPage(nil); fill(CGRect(x: 0, y: 0, width: W, height: H), .white)
    fill(CGRect(x: 0, y: H - 13, width: W, height: 13), teal)
    _ = text("TAPTIME", x: 46, top: H - 31, width: 100, size: 8.5, color: teal, bold: true, spacing: 0, paragraph: 0)
    _ = text(section.uppercased(), x: 330, top: H - 31, width: 218, size: 8, color: muted, spacing: 0, paragraph: 0, align: .right)
    fill(CGRect(x: 46, y: 31, width: 502, height: 1), line)
    _ = text("Partner discussion document", x: 46, top: 25, width: 180, size: 7.2, color: muted, spacing: 0, paragraph: 0)
    _ = text("\(number)", x: 510, top: 25, width: 38, size: 7.2, color: muted, spacing: 0, paragraph: 0, align: .right)
}

func endPage() { ctx.endPDFPage() }

func heading(_ number: String, _ title: String, top: CGFloat) -> CGFloat {
    _ = text(number, x: 46, top: top, width: 40, size: 12, color: gold, bold: true, spacing: 0, paragraph: 0)
    let b = text(title, x: 100, top: top + 1, width: 448, size: 23, color: navy, bold: true, spacing: 0, paragraph: 0)
    fill(CGRect(x: 100, y: b - 7, width: 58, height: 3), teal)
    return b - 24
}

func card(_ title: String, _ body: String, x: CGFloat, top: CGFloat, width: CGFloat, height: CGFloat, accent: NSColor = teal) {
    fill(CGRect(x: x, y: top - height, width: width, height: height), paper, radius: 8)
    fill(CGRect(x: x, y: top - height, width: 5, height: height), accent, radius: 2)
    _ = text(title, x: x + 15, top: top - 14, width: width - 28, size: 11, color: navy, bold: true, spacing: 0, paragraph: 0)
    _ = text(body, x: x + 15, top: top - 40, width: width - 28, size: 9, color: ink, spacing: 2, paragraph: 0)
}

func pill(_ label: String, x: CGFloat, y: CGFloat, width: CGFloat) {
    fill(CGRect(x: x, y: y, width: width, height: 25), aqua, radius: 12)
    _ = text(label, x: x, top: y + 18, width: width, size: 8.2, color: navy, bold: true, spacing: 0, paragraph: 0, align: .center)
}

// Cover
ctx.beginPDFPage(nil)
fill(CGRect(x: 0, y: 0, width: W, height: H), navy)
fill(CGRect(x: 0, y: 0, width: 17, height: H), teal)
fill(CGRect(x: 405, y: 585, width: 260, height: 260), NSColor(calibratedRed: 0.04, green: 0.25, blue: 0.29, alpha: 1), radius: 130)
fill(CGRect(x: 455, y: 635, width: 160, height: 160), teal, radius: 80)
_ = text("PRODUCT CONCEPT · AUGUST 2026", x: 55, top: 755, width: 330, size: 9, color: aqua, bold: true, spacing: 0, paragraph: 0)
_ = text("TapTime", x: 55, top: 658, width: 430, size: 49, color: .white, bold: true, spacing: 0, paragraph: 0)
_ = text("A trusted, contactless attendance system for modern workplaces and clinics", x: 58, top: 595, width: 405, size: 19, color: aqua, spacing: 3, paragraph: 0)
fill(CGRect(x: 58, y: 519, width: 64, height: 5), gold)
_ = text("Tap in. Tap out. Clear records.", x: 58, top: 476, width: 410, size: 16, color: .white, bold: true, spacing: 0, paragraph: 0)
_ = text("Prepared for founding-team discussion\nInitial scope: phone-first attendance · secure hardware · SAGA workflow · iSTOMA compatibility", x: 58, top: 420, width: 430, size: 10.5, color: NSColor(calibratedWhite: 0.82, alpha: 1), spacing: 3, paragraph: 0)
fill(CGRect(x: 58, y: 95, width: 470, height: 1), NSColor(calibratedWhite: 0.35, alpha: 1))
_ = text("CONFIDENTIAL WORKING CONCEPT", x: 58, top: 78, width: 250, size: 7.5, color: NSColor(calibratedWhite: 0.6, alpha: 1), bold: true, spacing: 0, paragraph: 0)
ctx.endPDFPage()

// Executive summary
beginPage(2, "Executive summary")
var y = heading("01", "The opportunity", top: 762)
_ = text("Manual attendance creates avoidable payroll work, uncertainty, and conflict. TapTime turns a physical tap into a verifiable attendance event that employees can see, managers can approve, and accountants can use.", x: 88, top: y, width: 445, size: 12.2, color: muted, spacing: 3.2, paragraph: 0)
card("The problem", "Late arrivals, early departures, forgotten entries, buddy-punching, and month-end reconstruction.", x: 46, top: 595, width: 242, height: 112, accent: gold)
card("The product", "A fixed workplace reader, phone-first employee credential, secure event service, and clear management dashboard.", x: 306, top: 595, width: 242, height: 112)
card("The customer value", "Less admin, fewer disputes, transparent records, and faster payroll preparation.", x: 46, top: 463, width: 242, height: 112)
card("The first market", "Private clinics and small or medium workplaces with approximately 5–100 employees.", x: 306, top: 463, width: 242, height: 112)
_ = text("POSITIONING", x: 46, top: 314, width: 120, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
fill(CGRect(x: 46, y: 176, width: 502, height: 110), aqua, radius: 9)
_ = text("An attendance and workforce-management tool — not a surveillance product.", x: 65, top: 263, width: 465, size: 16, color: navy, bold: true, spacing: 2, paragraph: 0)
_ = text("The system should create accurate, transparent records for both employees and employers, with visible corrections and an audit trail.", x: 65, top: 220, width: 455, size: 10, color: ink, spacing: 2.4, paragraph: 0)
pill("FAST", x: 47, y: 112, width: 72); pill("TRANSPARENT", x: 128, y: 112, width: 104); pill("TAMPER-EVIDENT", x: 241, y: 112, width: 118); pill("PAYROLL-READY", x: 368, y: 112, width: 112)
endPage()

// Product experience
beginPage(3, "Product experience")
y = heading("02", "From phone tap to payroll", top: 762)
_ = text("The value is the trusted chain—not the NFC tap by itself.", x: 88, top: y, width: 445, size: 12, color: muted, spacing: 3, paragraph: 0)
drawImage("/Users/vicorico/TapTime-product-concept.png", in: CGRect(x: 46, y: 328, width: 502, height: 278), radius: 10)
fill(CGRect(x: 46, y: 302, width: 502, height: 26), navy)
_ = text("ARRIVE → TAP PHONE → CONFIRMATION IN ABOUT A SECOND", x: 60, top: 320, width: 474, size: 8.5, color: .white, bold: true, spacing: 0, paragraph: 0, align: .center)
let mini = [("01", "IDENTIFY", "Registered phone or backup card"), ("02", "RECORD", "Signed time and reader location"), ("03", "VALIDATE", "Exceptions are automatically flagged"), ("04", "APPROVE", "Closed report goes to payroll")]
for (i,item) in mini.enumerated() {
    let x = 46 + CGFloat(i) * 128
    fill(CGRect(x: x, y: 151, width: 118, height: 118), i == 1 ? aqua : paper, radius: 8)
    _ = text(item.0, x: x + 11, top: 253, width: 28, size: 8.5, color: gold, bold: true, spacing: 0, paragraph: 0)
    _ = text(item.1, x: x + 11, top: 226, width: 96, size: 9, color: navy, bold: true, spacing: 0, paragraph: 0)
    _ = text(item.2, x: x + 11, top: 198, width: 96, size: 8.2, color: ink, spacing: 1.6, paragraph: 0)
}
_ = text("The employee does not need to open a timesheet. The workplace controls the trusted reader; the phone supplies the personal credential.", x: 46, top: 122, width: 500, size: 9.2, color: muted, spacing: 2, paragraph: 0)
endPage()

// Physical requirements
beginPage(4, "Physical requirements")
y = heading("03", "What is required on site", top: 762)
_ = text("The attendance-only MVP does not require replacing doors or installing a turnstile. Mount one reader near the entrance, connect it, enroll employees, and begin recording events.", x: 100, top: y, width: 433, size: 11.3, color: muted, spacing: 3, paragraph: 0)
let reqs = [
    ("1", "EMPLOYEE PHONE", "iPhone or Android phone with NFC and the TapTime app. The app stores a device-bound credential. Provide an NFC card or QR fallback."),
    ("2", "NFC READER", "13.56 MHz reader compatible with ISO/IEC 14443 / ISO-DEP, with an SDK or API, status light/buzzer, and support for secure challenge-response."),
    ("3", "EDGE CONTROLLER", "Small industrial controller—or Raspberry Pi-class device for the prototype—with encrypted storage, Ethernet/Wi-Fi, and an offline event queue."),
    ("4", "ENCLOSURE + POWER", "Wall enclosure, hidden or security fixings, tamper switch, protected 5V/12V supply, cable management, and optional small battery backup."),
    ("5", "CLOUD SERVICE", "API, employee directory, device registry, rules engine, audit log, dashboard, secure backups, and monthly payroll exports."),
    ("6", "INSTALLATION KIT", "Mounting template, screws/anchors, power cable, network setup instructions, test credential, and a simple enrollment checklist.")
]
for (i,r) in reqs.enumerated() {
    let top = 617 - CGFloat(i) * 83
    fill(CGRect(x: 46, y: top - 59, width: 502, height: 67), i % 2 == 0 ? paper : NSColor(calibratedRed: 0.94, green: 0.98, blue: 0.97, alpha: 1), radius: 7)
    fill(CGRect(x: 59, y: top - 45, width: 38, height: 38), teal, radius: 19)
    _ = text(r.0, x: 59, top: top - 21, width: 38, size: 10, color: .white, bold: true, spacing: 0, paragraph: 0, align: .center)
    _ = text(r.1, x: 115, top: top - 10, width: 128, size: 8.7, color: navy, bold: true, spacing: 0, paragraph: 0)
    _ = text(r.2, x: 244, top: top - 9, width: 286, size: 8.2, color: ink, spacing: 1.4, paragraph: 0)
}
_ = text("Phone NFC capabilities differ by platform and region, so iOS and Android behavior must be validated during the prototype. Android supports host card emulation on compatible devices; Apple documents NFC card sessions for eligible use cases in the EEA.", x: 46, top: 105, width: 500, size: 7.8, color: muted, spacing: 1.5, paragraph: 0)
endPage()

// Physical and security
beginPage(5, "Physical product & security")
y = heading("04", "Built as a secure appliance", top: 762)
_ = text("The MVP may use off-the-shelf parts, but the architecture should already support device identity, offline operation, and tamper detection.", x: 88, top: y, width: 445, size: 11.5, color: muted, spacing: 3, paragraph: 0)
_ = text("PHYSICAL CHAIN", x: 46, top: 618, width: 130, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
let xs: [CGFloat] = [46, 178, 310, 442]
let arch = [("PHONE", "App with a per-device cryptographic identity"), ("READER", "Registered device with visible feedback"), ("EDGE", "Encrypted offline queue and signed events"), ("CLOUD", "Verification, audit log, dashboard")]
for (i,a) in arch.enumerated() {
    fill(CGRect(x: xs[i], y: 487, width: 108, height: 105), i == 1 ? aqua : paper, radius: 8)
    _ = text(a.0, x: xs[i] + 10, top: 573, width: 88, size: 8.5, color: teal, bold: true, spacing: 0, paragraph: 0, align: .center)
    _ = text(a.1, x: xs[i] + 10, top: 545, width: 88, size: 8.3, color: ink, spacing: 1.8, paragraph: 0, align: .center)
    if i < 3 { _ = text("→", x: xs[i] + 109, top: 542, width: 23, size: 17, color: gold, bold: true, spacing: 0, paragraph: 0, align: .center) }
}
card("Tamper resistance", "Sealed wall enclosure, hidden fixings, opening switch, locked power, and logged device health.", x: 46, top: 453, width: 242, height: 105)
card("Authenticity", "Device-bound phone key, unique reader certificate, mutual TLS, signed firmware/events, and controlled key management.", x: 306, top: 453, width: 242, height: 105)
card("Resilience", "Encrypted local storage, safe offline queue, automatic synchronization, and no silent history overwrite.", x: 46, top: 330, width: 242, height: 105)
card("Accountability", "Role-based access, visible corrections, immutable audit history, and stronger approval for payroll overrides.", x: 306, top: 330, width: 242, height: 105)
fill(CGRect(x: 46, y: 105, width: 502, height: 91), NSColor(calibratedRed: 0.99, green: 0.95, blue: 0.86, alpha: 1), radius: 8)
_ = text("A serious security promise", x: 63, top: 177, width: 210, size: 11.5, color: navy, bold: true, spacing: 0, paragraph: 0)
_ = text("No connected system is literally “unhackable.” TapTime should promise that unauthorized events are difficult to create, tampering is detectable, and every correction is accountable.", x: 63, top: 149, width: 462, size: 9.2, color: ink, spacing: 2, paragraph: 0)
endPage()

// Integrations
beginPage(6, "SAGA & iSTOMA")
y = heading("05", "Integration strategy", top: 762)
_ = text("Integration claims must be validated with the exact software edition, version, and provider-supported route before being promised to customers.", x: 88, top: y, width: 445, size: 11.5, color: muted, spacing: 3, paragraph: 0)
card("SAGA · payroll destination", "TapTime provides employee ID, normal hours, absences, overtime, and approved corrections. Start with an accountant-approved CSV/XML/report. Investigate direct import or API only after the exact SAGA product and version are confirmed.", x: 46, top: 604, width: 502, height: 143, accent: gold)
card("iSTOMA · clinic context", "Potential uses include staff identity, schedules, and clinic working periods. Ask iSTOMA for an official API or approved import/export method. If unavailable, TapTime remains the attendance source and supplies reports.", x: 46, top: 439, width: 502, height: 132)
_ = text("PROVIDER CHECKLIST", x: 46, top: 279, width: 170, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
_ = text("01  Public or partner API available?\n02  Attendance/pontaj imports supported?\n03  Exact accepted fields and file format?\n04  Stable unique employee IDs supported?\n05  Licensing, certification, or support requirements?", x: 62, top: 246, width: 455, size: 10.2, color: ink, spacing: 4.7, paragraph: 1)
_ = text("Initial references reviewed: SAGA payroll documentation, iSTOMA public product information, and Brick’s official product description. Provider confirmation remains a discovery task.", x: 46, top: 100, width: 500, size: 7.8, color: muted, spacing: 1.5, paragraph: 0)
endPage()

// Business impact and deployment
beginPage(7, "Business impact & deployment")
y = heading("06", "Easy to launch. Easy to measure.", top: 762)
_ = text("TapTime does not need to prove that every minute is intentional. It needs to make attendance visible, reduce preventable leakage, and remove manual reconstruction from payroll.", x: 100, top: y, width: 433, size: 11.2, color: muted, spacing: 3, paragraph: 0)
_ = text("ILLUSTRATIVE TIME-RECOVERY SCENARIOS", x: 46, top: 618, width: 250, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
card("250 hours / year", "One employee leaves one hour early on each of approximately 250 working days.", x: 46, top: 584, width: 154, height: 112, accent: gold)
card("365 hours / year", "The business loses one combined hour every calendar day—for example, a seven-day operation.", x: 220, top: 584, width: 154, height: 112)
card("625 hours / year", "Ten employees lose 15 minutes per working day: 10 × 0.25 × 250.", x: 394, top: 584, width: 154, height: 112)
fill(CGRect(x: 46, y: 382, width: 502, height: 80), aqua, radius: 8)
_ = text("Simple value formula", x: 62, top: 448, width: 160, size: 9.4, color: navy, bold: true, spacing: 0, paragraph: 0)
_ = text("Potential labor value = recovered hours × loaded hourly cost", x: 62, top: 424, width: 455, size: 12.8, color: navy, bold: true, spacing: 0, paragraph: 0)
_ = text("Admin example: reducing 4–8 hours of monthly reconciliation by half saves another 24–48 hours per year.", x: 62, top: 398, width: 455, size: 7.8, color: ink, spacing: 1, paragraph: 0)
_ = text("IMPLEMENTATION — ATTENDANCE-ONLY MVP", x: 46, top: 350, width: 260, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
let launch = [("DAY 0", "Mount reader, connect power/network, create company and administrator."), ("DAY 1", "Enroll phones and fallback cards; test check-in and check-out."), ("WEEK 1", "Run beside the existing process; train managers on exceptions."), ("MONTH END", "Close attendance, approve corrections, export the payroll report.")]
for (i,l) in launch.enumerated() {
    let top = 317 - CGFloat(i) * 54
    _ = text(l.0, x: 47, top: top, width: 78, size: 8.3, color: gold, bold: true, spacing: 0, paragraph: 0)
    _ = text(l.1, x: 130, top: top, width: 410, size: 9.2, color: ink, spacing: 1.7, paragraph: 0)
    fill(CGRect(x: 46, y: top - 37, width: 502, height: 1), line)
}
_ = text("Illustrative scenarios—not guaranteed savings. Use the pilot to establish the actual baseline and measure current payroll-preparation time before deployment.", x: 46, top: 94, width: 500, size: 7.8, color: muted, spacing: 1.5, paragraph: 0)
endPage()

// Pilot plan
beginPage(8, "MVP plan")
y = heading("07", "Prove it in one workplace", top: 762)
_ = text("The fastest credible route is a small pilot that proves event capture, correction handling, employee acceptance, and payroll usefulness.", x: 88, top: y, width: 445, size: 11.5, color: muted, spacing: 3, paragraph: 0)
let phases = [("1–2 WEEKS", "DISCOVERY", "Choose a pilot, map rules, confirm SAGA workflow, contact iSTOMA, select hardware."), ("2–4 WEEKS", "PROTOTYPE", "Build enrollment, tap events, check-in/out logic, dashboard, and event history."), ("4 WEEKS", "PILOT", "Deploy at one entrance, compare records, measure exceptions, and test offline recovery."), ("2–4 WEEKS", "PAYROLL", "Finalize reports with the accountant; add approvals, closing, and audit outputs."), ("AFTER PROOF", "SCALE", "Add locations, phone credentials, shifts, integrations, billing, and support.")]
for (i,p) in phases.enumerated() {
    let top = 610 - CGFloat(i) * 93
    fill(CGRect(x: 46, y: top - 62, width: 502, height: 70), paper, radius: 7)
    fill(CGRect(x: 46, y: top - 62, width: 92, height: 70), i == 2 ? gold : teal, radius: 7)
    _ = text(p.0, x: 54, top: top - 18, width: 76, size: 7.7, color: .white, bold: true, spacing: 0, paragraph: 0, align: .center)
    _ = text(p.1, x: 157, top: top - 12, width: 110, size: 10, color: navy, bold: true, spacing: 0, paragraph: 0)
    _ = text(p.2, x: 157, top: top - 34, width: 370, size: 8.8, color: ink, spacing: 1.7, paragraph: 0)
}
_ = text("PILOT GATE", x: 46, top: 127, width: 100, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
_ = text("≥95% events captured • corrections are auditable • employees can see their records • accountant accepts the output • no critical security or privacy issue remains", x: 46, top: 101, width: 500, size: 9.2, color: navy, bold: true, spacing: 2, paragraph: 0)
endPage()

// Decisions
beginPage(9, "Founding-team decisions")
y = heading("08", "What we decide next", top: 762)
let decisions = [("TARGET", "Private clinics and small/medium businesses with 5–100 employees."), ("CREDENTIAL", "Phone-first; NFC card or key fob as fallback and for employees without compatible phones."), ("HARDWARE", "One fixed reader per entrance, connected by Ethernet or managed Wi-Fi."), ("MODEL", "One-time hardware fee plus monthly software fee per location or employee."), ("FIRST PROOF", "One functioning pilot and one accountant-approved SAGA report.")]
for (i,d) in decisions.enumerated() {
    let top = 644 - CGFloat(i) * 78
    _ = text(d.0, x: 46, top: top, width: 93, size: 8.5, color: teal, bold: true, spacing: 0, paragraph: 0)
    _ = text(d.1, x: 154, top: top, width: 390, size: 10.2, color: ink, spacing: 2, paragraph: 0)
    fill(CGRect(x: 46, y: top - 45, width: 502, height: 1), line)
}
_ = text("IMMEDIATE ACTIONS", x: 46, top: 229, width: 170, size: 9, color: teal, bold: true, spacing: 0, paragraph: 0)
_ = text("1  Choose one pilot workplace and document its current attendance process.\n2  Prototype the phone tap on both iOS and Android; keep card/QR fallback.\n3  Confirm the exact SAGA edition/version and required payroll fields.\n4  Ask iSTOMA about official API/import availability.\n5  Build the pilot before investing in custom hardware.", x: 58, top: 199, width: 470, size: 9.3, color: ink, spacing: 2.3, paragraph: 0)
fill(CGRect(x: 46, y: 52, width: 502, height: 58), navy, radius: 8)
_ = text("Trusted physical event  →  verified attendance  →  approved payroll", x: 62, top: 89, width: 470, size: 11.4, color: .white, bold: true, spacing: 0, paragraph: 0, align: .center)
// Closing-page masthead: intentionally stronger than the standard section header.
fill(CGRect(x: 0, y: 720, width: W, height: 122), navy)
fill(CGRect(x: 0, y: 720, width: 16, height: 122), teal)
_ = text("08", x: 46, top: 796, width: 36, size: 11, color: gold, bold: true, spacing: 0, paragraph: 0)
_ = text("What we decide next", x: 94, top: 804, width: 430, size: 25, color: .white, bold: true, spacing: 0, paragraph: 0)
_ = text("FOUNDING-TEAM DECISIONS", x: 95, top: 756, width: 310, size: 8, color: aqua, bold: true, spacing: 0, paragraph: 0)
endPage()

ctx.closePDF()
print(output)
