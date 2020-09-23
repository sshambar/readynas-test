
TARFILE=mytest-1.0-arm.tgz

TEST10: TEST10/files/tmp/test-addon.deb
	cd TEST10; ../scripts/create-addon

TEST10/files/tmp/test-addon.deb: test-addon/DEBIAN/* test-addon/usr/local/sbin/mytest $(TARFILE)
	FAKEROOT=$$(command -v fakeroot); $$FAKEROOT dpkg-deb -b test-addon $@

test-addon/usr/local/sbin/mytest:
	make $(TARFILE)
	cd test-addon; tar xzf ../$(TARFILE)

$(TARFILE): mytest/usr/local/sbin/mytest
	FAKEROOT=$$(command -v fakeroot); $$FAKEROOT tar czf $@ -C mytest usr

clean:
	rm -f TEST10/Test10_*.bin
	rm -f TEST10/files/tmp/test-addon.deb
	cd TEST10; ../scripts/create-addon clean

clobber: clean
	rm -rf test-addon/usr
	rm -f $(TARFILE)

.PHONY: TEST10 clean clobber
