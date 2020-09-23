
TARFILE=samba-3.6.25-arm.tgz

SAMBA36: SAMBA36/files/tmp/samba36-addon.deb
	cd SAMBA36; ../../scripts/create-addon

SAMBA36/files/tmp/samba36-addon.deb: samba36-addon/DEBIAN/* samba36-addon/usr/local/sbin/smbd $(TARFILE)
	FAKEROOT=$$(command -v fakeroot); $$FAKEROOT dpkg-deb -b samba36-addon $@

samba36-addon/usr/local/sbin/smbd:
	make $(TARFILE)
	cd samba36-addon; tar xzf ../$(TARFILE); rm -rf var etc

$(TARFILE):
	build samba3 tar TARDIR=$$(pwd)

clean:
	rm -f SAMBA36/Samba36_*.bin 
	rm -f SAMBA36/files/tmp/samba36-addon.deb
	cd SAMBA36; ../../scripts/create-addon clean

clobber: clean
	rm -rf samba36-addon/usr
	rm -f $(TARFILE)

.PHONY: SAMBA36 clean clobber
