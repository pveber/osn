include $(shell opam config var solvuu-build:lib)/solvuu.mk

all:
	$(OCAMLBUILD) .merlin .ocamlinit \
                      evolnet.cma app/evolnet_app.byte \
		      evolnet.cmxa evolnet.cmxs \
                      app/evolnet_app.native
