.DEFAULT_GOAL := generate

ifeq ($(PREFIX),)
	PREFIX := /usr/local
endif
BINDIR = $(PREFIX)/bin
TARGET = status-string-maker

generate:
	raco exe status-string-maker.rkt

clean:
	rm status-string-maker

install: generate
	install -D $(TARGET) $(BINDIR)/$(TARGET)

uninstall:
	-rm $(BINDIR)/$(TARGET)
