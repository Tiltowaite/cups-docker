#!/bin/sh

until lpstat -r 2>/dev/null | grep -q "scheduler is running"; do
    echo "Waiting for CUPS..."
    sleep .2
done

# Add Canon MF4320 (USB)
lpadmin -p CanonMF4320 \
  -E \
  -v "usb://Canon/MF4320-4350%20(UFRII%20LT)?serial=SJ3013833704G&interface=1" \
  -m CNRCUPSMF4350ZS.ppd \
  -L "Upstairs" \
  -D "Canon MF4320"

lpadmin -p CanonMF4320 -o media=Letter
lpadmin -p CanonMF4320 -o sides=one-sided
lpadmin -p CanonMF4320 -o print-color-mode=monochrome
lpadmin -p CanonMF4320 -o Resolution=600dpi
lpadmin -p CanonMF4320 -o printer-is-shared=true

cupsenable CanonMF4320
cupsaccept CanonMF4320

# Add Canon MG7700 (Network)
#if [ -n "$CANON7700" ]; then
#   lpadmin -p CanonMG7700_ipp \
#     -E \
#     -v "ipp://$CANON7700/ipp/print" \
#     -m canonmg7700.ppd \
#     -L "Office" \
#     -D "Canon MG7700 IPP"

# lpadmin -p CanonMG7700_ipp -o media=Letter
# lpadmin -p CanonMG7700_ipp -o sides=one-sided
# lpadmin -p CanonMG7700_ipp -o print-color-mode=color
# lpadmin -p CanonMG7700_ipp -o Resolution=600dpi
#
# cupsenable CanonMG7700_ipp
# cupsaccept CanonMG7700_ipp
#fi

if [ -n "$CANON7700" ]; then
  lpadmin -p CanonMG7700_bjnp \
    -E \
    -v bjnp://$CANON7700:8611 \
    -m canonmg7700.ppd \
    -L "Office" \
    -D "Canon MG7700"
 lpadmin -p CanonMG7700_bjnp -o media=Letter
 lpadmin -p CanonMG7700_bjnp -o sides=one-sided
 lpadmin -p CanonMG7700_bjnp -o print-color-mode=color
 lpadmin -p CanonMG7700_bjnp -o Resolution=600dpi

 cupsenable CanonMG7700_bjnp
 cupsaccept CanonMG7700_bjnp
fi

lpadmin -p Server_PDF_Print \
  -E \
  -v cups-pdf:/ \
  -P /usr/share/ppd/cupsfilters/Generic-PDF_Printer-PDF.ppd \
  -D "PDF Printer"

lpadmin -p Server_PDF_Print -o media=Letter
lpadmin -p Server_PDF_Print -o sides=one-sided
lpadmin -p Server_PDF_Print -o print-color-mode=color
lpadmin -p Server_PDF_Print -o Resolution=600dpi
cupsenable Server_PDF_Print
cupsaccept Server_PDF_Print