#ifndef PARSE_FLAGS_H
#define PARSE_FLAGS_H

//////////////////////////////////////////////////////////////////////
//////////////////////////// Parse Flags /////////////////////////////
//////////////////////////////////////////////////////////////////////

//returns true if flag is present, false otherwise
namespace FLAG {
	template <class T>
	bool get(int argc, char* argv[], const char* flag, T* value, T def = nullptr) {
		for(int i = 0; i < argc; i++) {
			if(strcmp(argv[i], flag) == 0) {
				if (typeid(T) == typeid(char*)) {
					char* res = (char*) &(argv[i+1]);
					if(value != nullptr) {
						memcpy(value, res, sizeof(char*));
					}
					return true;
				} else if (typeid(T) == typeid(int)) {
					int res = std::stoi(argv[i+1]);
					if(value != nullptr) {
						memcpy(value, &res, sizeof(int));
					}
					return true;
				} else if (typeid(T) == typeid(double)) {
					double res = atof(argv[i+1]);
					if(value != nullptr) {
						memcpy(value, &res, sizeof(double));
					}
					return true;
				} else if (typeid(T) == typeid(void*)) {
					return true;
				} else {
					fprintf(stderr, "Invalid type T in getFlag");
					exit(1);
				}
	
			}
		}
		if(value != nullptr) {
			memcpy(value, &def, sizeof(T));
		}
		return false;
	}
}


#endif