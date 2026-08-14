# TapTime MVP

A solid, cased passive-NFC attendance checkpoint prototype and product landing page based on the TapTime proposal.

## Print the enclosure

Use the ready-made files in `cad/output/` or open `cad/taptime-enclosure.scad` to adjust dimensions.

- Print the front case face-down and the rear case flat-side-down.
- Material: PLA or PETG; 0.20 mm layers; 3 walls; 15–20% infill; no supports.
- Insert a 25 mm NTAG213 or NTAG215 sticker into the circular cradle inside the front case.
- Program the tag with the unique HTTPS check-in URL for that workplace.
- Optional: glue two 15 × 3 mm neodymium magnets into the rear pockets, or use two countersunk wall screws.
- Press the rear case into the front case; the locating lip and four pegs retain the assembly.
- Test-fit first. For a tight printer, scale only the rear case to 99.5% in X/Y or lightly sand the pegs.

The assembled enclosure is 56 × 56 × 17 mm. The front is 11 mm deep, the rear is 6 mm, and the NFC tag is fully enclosed rather than exposed like a card.

## Run the website

```bash
npm start
```

Then open `http://localhost:4173`.

## MVP architecture

The NFC tag should contain a location-specific HTTPS link, not employee data. The web flow authenticates the employee, asks them to confirm check-in or check-out, and sends the event to the server. A passive tag is excellent for testing behavior, but it can be copied; production deployments needing stronger proof should use a powered reader with device identity and signed events.
