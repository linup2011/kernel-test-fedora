# Makefile

TARGET	:= $(patsubst %.c,%,$(wildcard *.c))

all : $(TARGET)
.PHONY : all
% : %.c
	cc $^ -o $@

.PHONY : clean
clean :
	rm -f $(TARGET)
