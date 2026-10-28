#!/bin/sh

until lpstat -r 2>/dev/null | grep -q "scheduler is running"; do
    echo "Waiting for CUPS..."
    sleep .2
done

# Add Canon MF4320 (USB)
lpadmin -p CanonMF4320 \
  -E \
  -v "usb://Canon/MF4320-4350%20(UFRII%20LT)?serial=SJ3013833704G&interface=1" \
  -P /usr/share/cups/model/CNRCUPSMF4350ZS.ppd \
  -L "Upstairs" \
  -D "Canon MF4320"


lpadmin -p CanonMF4320 -o media=Letter
lpadmin -p CanonMF4320 -o sides=one-sided
lpadmin -p CanonMF4320 -o print-color-mode=monochrome
lpadmin -p CanonMF4320 -o Resolution=600dpi
lpadmin -p CanonMF4320 -o printer-is-shared=true

cupsenable CanonMF4320
cupsaccept CanonMF4320

lpoptions -p CanonMF4320 -l
lpoptions -p CanonMF4320

lpadmin -p Server_PDF_Print \
  -E \
  -v cups-pdf:/ \
  -P /usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd \
  -L "Virtual" \
  -D "PDF Printer"

lpadmin -p Server_PDF_Print -o media=Letter
lpadmin -p Server_PDF_Print -o sides=one-sided
lpadmin -p Server_PDF_Print -o print-color-mode=color
lpadmin -p Server_PDF_Print -o Resolution=600dpi
lpadmin -p Server_PDF_Print -o printer-is-shared=true

cupsenable Server_PDF_Print
cupsaccept Server_PDF_Print

lpoptions -p Server_PDF_Print -l
lpoptions -p Server_PDF_Print
