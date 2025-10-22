#
# Makefile
# =============================================================================
# Customers API Lite microservice prototype (LFE/OTP port). Version 0.0.1
# =============================================================================
# A daemon written in LFE (Lisp Flavoured Erlang), designed and intended
# to be run as a microservice, implementing a special Customers API prototype
# with a smart yet simplified data scheme.
# =============================================================================
# (See the LICENSE file at the top of the source tree.)
#

PROF = default
PREF = api-lite

REL_DIR = _build/$(PROF)/rel/$(PREF)d/lib
BIN_DIR = _build/$(PROF)/lib/$(PREF)/ebin
SRC_DIR = src

BEAM = $(BIN_DIR)/$(PREF)-app.beam \
       $(BIN_DIR)/$(PREF)-sup.beam \
       $(BIN_DIR)/$(PREF)-helper.beam \
       $(BIN_DIR)/$(PREF).app

DEPS = $(SRC_DIR)/$(PREF)-app.lfe \
       $(SRC_DIR)/$(PREF)-sup.lfe \
       $(SRC_DIR)/$(PREF)-helper.lfe \
       $(SRC_DIR)/$(PREF).app.src

# Specify flags and other vars here.
REBAR3 = rebar3
LFE    = lfe

# Making the first target (Erlang BEAMs).
$(BEAM): $(DEPS)
	$(REBAR3) $(LFE) compile

# Making the second target (OTP release).
$(REL_DIR): $(BEAM)
	$(REBAR3) $(LFE) release

.PHONY: all clean

all: $(REL_DIR)

clean:
	$(REBAR3) $(LFE) clean

# vim:set nu et ts=4 sw=4:
