ifndef VERBOSE
.SILENT:
endif

cpp_files := $(wildcard *.cpp)
h_files := $(wildcard *.h)
cu_files := $(wildcard *.cu)

object_files := $(addprefix ./bin/, $(cpp_files:.cpp=.o) $(cu_files:.cu=.o))

filter: ./bin/filter

./bin/filter: $(cpp_files) $(h_files) $(cu_files)
	g++ main.cpp -o ./bin/filter

# ./bin/%.o : %.cpp
# 	g++ -dc $< -o $@

# ./bin/%.o : %.cu
#     nvcc -dc $< -o $@

run: ./bin/filter
	./bin/filter



clean:
	rm -rf kmeans *.o ./bin/*