ifndef VERBOSE
# .SILENT:
endif

ifdef pic
in := inputImages/$(pic).jpg
out := outputImages/$(pic).jpg
endif

ifdef in
inCmd := -in $(in)
endif

ifdef out
outCmd := -out $(out)
endif

ifdef s
sCmd := -s $(s)
endif

impl ?= seq

cpp_files := $(wildcard *.cpp)
h_files := $(wildcard *.h)
cu_files := $(wildcard *.cu)
depends := $(cpp_files) $(h_files) $(cu_files)

object_files := $(addprefix ./bin/, $(cpp_files:.cpp=.o) $(cu_files:.cu=.o))

all: filter

filter: ./bin/filter

./bin/filter: $(object_files) $(h_files)
	nvcc $(object_files) -o ./bin/filter

./bin/%.o : %.cu
	nvcc -dc $< -o $@ -Xcudafe "--diag_suppress=set_but_not_used"

./bin/%.o : %.cpp
	nvcc -dc $< -o $@

run: $(depends) ./bin/filter
	./bin/filter $(inCmd) $(outCmd) -impl $(impl) -f $(filter) $(sCmd)



clean:
	rm -rf ./bin/* outputImages/*.jpg