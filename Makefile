TARGET		= demo
SRC_DIR		?= src
COBC		?= cobc
COBCFLAGS	= -x -O -fstatic-call -Wall -Wextra -Wadditional -Werror -Wpossible-truncate \
			  -Wpossible-overlap -Wstrict-typing -Wimplicit-define -Wno-call-params \
			  -Wcolumn-overflow -Wterminator -Wlinkage -Wunreachable -Wdangling-text \
			  -fdiagnostics-plain-output -Werror

LIBS		= -lSDL2 -lSDL2_image -lSDL2_mixer -lSDL2_ttf

$(TARGET): $(SRC_DIR)/MAIN.CBL
	$(COBC) $(COBCFLAGS) $< $(LIBS) -o $@

.PHONY: all clean run rebuild

all: $(TARGET)

clean:
	rm -f $(TARGET)

run: $(TARGET)
	./$<

rebuild: clean all

