#Compiler and Linker
CC          := g++

#The Target Binary Program
TARGET      := converter

#Build type
BUILD       := product

#The Directories, Source, Includes, Objects, Binary and Resources
SRCDIR      := src
INCDIR      := include
BUILDDIR    := obj
TARGETDIR   := bin
SRCEXT      := cpp
DEPEXT      := d
OBJEXT      := o

#Flags, Libraries and Includes
CFLAGS      := -Wall -O3 -g -std=c++17
LIB         := -lm
INC         := -I$(INCDIR) -I/usr/local/include
INCDEP      := -I$(INCDIR)
LIBDEP      :=

# Root
ROOT_INC    := `root-config --incdir`
ROOT_LIB    := `root-config --libs --cflags`

INC         += -I$(ROOT_INC)
LIBDEP      += $(ROOT_LIB)
LIB         += $(ROOT_LIB)

LIBDEP      += -lyaml-cpp
LIB         += -lyaml-cpp

#---------------------------------------------------------------------------------
# DO NOT EDIT BELOW THIS LINE
#---------------------------------------------------------------------------------

ifeq ($(BUILD),product)
  CFLAGS    += -DNDEBUG
endif

SOURCES     := $(shell find $(SRCDIR) -type f -name *.$(SRCEXT))
OBJECTS     := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.$(OBJEXT)))

# Default make
all: directories $(TARGET)

# Remake
remake: cleaner all

# Make the Directories
directories:
	@mkdir -p $(TARGETDIR)
	@mkdir -p $(BUILDDIR)

# Clean only objects
clean:
	@$(RM) -rf $(BUILDDIR)

# Full clean: objects and binaries
cleaner: clean
	@$(RM) -rf $(TARGETDIR)

# Pull in dependency info for *existing* .o files
-include $(OBJECTS:.$(OBJEXT)=.$(DEPEXT))

# Link
$(TARGET): $(OBJECTS)
	$(CC) -o $(TARGETDIR)/$(TARGET) $^ $(LIB)

# Compile
$(BUILDDIR)/%.$(OBJEXT): $(SRCDIR)/%.$(SRCEXT)
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $(INC) $(LIBDEP) -c -o $@ $<
	@$(CC) $(CFLAGS) $(INCDEP) $(LIBDEP) -MM $(SRCDIR)/$*.$(SRCEXT) > $(BUILDDIR)/$*.$(DEPEXT)
	@cp -f $(BUILDDIR)/$*.$(DEPEXT) $(BUILDDIR)/$*.$(DEPEXT).tmp
	@sed -e 's|.*:|$(BUILDDIR)/$*.$(OBJEXT):|' < $(BUILDDIR)/$*.$(DEPEXT).tmp > $(BUILDDIR)/$*.$(DEPEXT)
	@sed -e 's/.*://' -e 's/\\$$//' < $(BUILDDIR)/$*.$(DEPEXT).tmp | fmt -1 | sed -e 's/^ *//' -e 's/$$/:/' >> $(BUILDDIR)/$*.$(DEPEXT)
	@rm -f $(BUILDDIR)/$*.$(DEPEXT).tmp

# Non-file targets
.PHONY: all remake clean cleaner resources
