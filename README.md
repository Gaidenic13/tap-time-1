# TapTime MVP

A passive-NFC attendance checkpoint prototype and product landing page based on the TapTime proposal.

## Print the enclosure

Use the ready-made files in `cad/output/` or open `cad/taptime-enclosure.scad` to adjust dimensions.

- Print the face shell face-down and the wall plate flat-side-down.
- Material: PLA or PETG; 0.20 mm layers; 3 walls; 15–20% infill; no supports.
- Insert a 25 mm NTAG213 or NTAG215 sticker into the circular pocket behind the face.
- Program the tag with the unique HTTPS check-in URL for that workplace.
- Attach the wall plate with two countersunk screws or high-bond tape, then press the face onto its four pegs.
- Test-fit first. For a tight printer, scale only the wall plate to 99.5% in X/Y or lightly sand the pegs.

The face shell is 60 × 60 × 8 mm; the assembled depth is about 12 mm.

## Run the website

```bash
npm start
```

Then open `http://localhost:4173`.

## MVP architecture

The NFC tag should contain a location-specific HTTPS link, not employee data. The web flow authenticates the employee, asks them to confirm check-in or check-out, and sends the event to the server. A passive tag is excellent for testing behavior, but it can be copied; production deployments needing stronger proof should use a powered reader with device identity and signed events.
