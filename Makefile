ifndef VERBOSE
.SILENT:
endif

cpp_files := $(wildcard *.cpp)
h_files := $(wildcard *.h)
cu_files := $(wildcard *.cu)
depends := $(cpp_files) $(h_files) $(cu_files)

object_files := $(addprefix ./bin/, $(cpp_files:.cpp=.o) $(cu_files:.cu=.o))


./bin/filter: $(depends)
	g++ main.cpp -o ./bin/filter

# ./bin/%.o : %.cpp
# 	g++ -dc $< -o $@

# ./bin/%.o : %.cu
#     nvcc -dc $< -o $@

run: $(depends) ./bin/filter
	./bin/filter -in $(in) -out $(out)




clean:
	rm -rf kmeans *.o ./bin/*