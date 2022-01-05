MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

# Monarch release versions
ARCHIVE ?= https://data-test.monarchinitiative.org/monarch/202109
UI_RELEASE ?= https://github.com/monarch-initiative/monarch-ui/releases/latest/download/static-assets.tar.gz

DATADIR ?= ./data
MONARCH_GID ?= 14728
SOLR_GID ?= 8983


WGET = /usr/bin/wget --timestamping --no-verbose

SOLR = $(DATADIR)/solr.tgz

OWLSIM_FILES = \
	$(DATADIR)/owlsim/all.owl \
	$(DATADIR)/owlsim/owlsim.cache \
	$(DATADIR)/owlsim/ic-cache.owl

SCIGRAPH_DATA = $(DATADIR)/scigraph.tgz

SCIGRAPH_ONTOLOGY = $(DATADIR)/scigraph-ontology.tgz

DATA_CONF = $(DATADIR)/scigraph-data/conf/scigraph-data.yaml

ONTOLOGY_CONF = $(DATADIR)/scigraph-ontology/conf/scigraph-ontology.yaml

MONARCH_UI = $(DATADIR)/static-assets.tar.gz

DATA_GRAPH = $(DATADIR)/scigraph-data/graph

ONTOLOGY_GRAPH = $(DATADIR)/scigraph-ontology/graph

SOLR_DATA = $(DATADIR)/solr/data

MONARCH_UI_DIST = $(DATADIR)/monarch-ui/dist


.PHONY: fetch_scigraph_ontology fetch_scigraph_data fetch_solr fetch_ui fetch_owlsim list

list:
	@LC_ALL=C $(MAKE) -pRrq -f $(lastword $(MAKEFILE_LIST)) : 2>/dev/null | awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$'


all: fetch_scigraph_ontology fetch_scigraph_data fetch_solr fetch_ui fetch_owlsim

fetch_scigraph_ontology: $(ONTOLOGY_GRAPH) $(ONTOLOGY_CONF)

fetch_scigraph_data: $(DATA_GRAPH) $(DATA_CONF)

fetch_solr: $(SOLR_DATA)

fetch_ui: $(MONARCH_UI_DIST)

fetch_owlsim: $(OWLSIM_FILES)


$(SCIGRAPH_DATA):
	cd $(DATADIR) && $(WGET) $(ARCHIVE)/scigraph.tgz
	chgrp $(MONARCH_GID) $@

$(SCIGRAPH_ONTOLOGY):
	cd $(DATADIR) && $(WGET) $(ARCHIVE)/scigraph-ontology.tgz
	chgrp $(MONARCH_GID) $@

$(SOLR):
	cd $(DATADIR) && $(WGET) $(ARCHIVE)/solr.tgz
	chgrp $(MONARCH_GID) $@

$(MONARCH_UI):
	cd $(DATADIR) && $(WGET) $(UI_RELEASE)
	chgrp $(MONARCH_GID) $@

$(OWLSIM_FILES):
	mkdir $(DATADIR)/owlsim-new
	cd $(DATADIR)/owlsim-new && $(WGET) $(ARCHIVE)/owlsim/all.owl
	cd $(DATADIR)/owlsim-new && $(WGET) $(ARCHIVE)/owlsim/ic-cache.owl
	cd $(DATADIR)/owlsim-new && $(WGET) $(ARCHIVE)/owlsim/owlsim.cache
	chgrp --recursive $(MONARCH_GID) $(DATADIR)/owlsim-new
	rm -rf $(DATADIR)/owlsim-old
	mv $(DATADIR)/owlsim $(DATADIR)/owlsim-old || true
	mv $(DATADIR)/owlsim-new $(DATADIR)/owlsim

$(DATA_GRAPH): $(SCIGRAPH_DATA)
	mkdir --parents $(DATADIR)/scigraph-data-new/data
	tar -I pigz -xf $(SCIGRAPH_DATA) --no-same-owner --directory $(DATADIR)/scigraph-data-new/data
	chgrp --recursive $(MONARCH_GID) $(DATADIR)/scigraph-data-new
	chmod --recursive g+w $(DATADIR)/scigraph-data-new
	rm -rf $(DATADIR)/scigraph-data-old
	mv $(DATADIR)/scigraph-data $(DATADIR)/scigraph-data-old || true
	mv $(DATADIR)/scigraph-data-new $(DATADIR)/scigraph-data

$(ONTOLOGY_GRAPH): $(SCIGRAPH_ONTOLOGY)
	mkdir --parents $(DATADIR)/scigraph-ontology-new/data
	tar -I pigz -xf $(SCIGRAPH_ONTOLOGY) --no-same-owner --directory $(DATADIR)/scigraph-ontology-new/data
	chgrp --recursive $(MONARCH_GID) $(DATADIR)/scigraph-ontology-new
	chmod --recursive g+w $(DATADIR)/scigraph-ontology-new
	rm -rf $(DATADIR)/scigraph-ontology-old
	mv $(DATADIR)/scigraph-ontology $(DATADIR)/scigraph-ontology-old || true
	mv $(DATADIR)/scigraph-ontology-new $(DATADIR)/scigraph-ontology

$(DATA_CONF): | $(DATA_GRAPH)
	mkdir --parents $(DATADIR)/scigraph-data/conf
	cd $(DATADIR)/scigraph-data/conf && $(WGET) $(ARCHIVE)/conf/scigraph-data.yaml
	chgrp --recursive $(MONARCH_GID) $(DATADIR)/scigraph-data/conf

$(ONTOLOGY_CONF): | $(ONTOLOGY_GRAPH)
	mkdir --parents $(DATADIR)/scigraph-ontology/conf
	cd $(DATADIR)/scigraph-ontology/conf && $(WGET) $(ARCHIVE)/conf/scigraph-ontology.yaml
	chgrp --recursive $(MONARCH_GID) $(DATADIR)/scigraph-ontology/conf

$(SOLR_DATA): $(SOLR)
	mkdir $(DATADIR)/solr-new
	tar -I pigz -xf $(SOLR) --no-same-owner --directory $(DATADIR)/solr-new
	chgrp --recursive $(SOLR_GID) $(DATADIR)/solr-new
	chmod --recursive g+w $(DATADIR)/solr-new
	rm -rf $(DATADIR)/solr-old
	mv $(DATADIR)/solr $(DATADIR)/solr-old || true
	mv $(DATADIR)/solr-new $(DATADIR)/solr

$(MONARCH_UI_DIST): $(MONARCH_UI)
	mkdir $(DATADIR)/monarch-ui-new
	tar -I pigz -xf $(MONARCH_UI) --no-same-owner --directory $(DATADIR)/monarch-ui-new
	chgrp --recursive $(MONARCH_GID) $(DATADIR)/monarch-ui-new
	chmod --recursive g+w $(DATADIR)/monarch-ui-new
	rm -rf $(DATADIR)/monarch-ui-old
	mv $(DATADIR)/monarch-ui $(DATADIR)/monarch-ui-old || true
	mv $(DATADIR)/monarch-ui-new $(DATADIR)/monarch-ui
