NAME = ft_turing

CML = ocamlfind ocamlopt -package yojson -linkpkg
CFLAGS = 

RM = rm
RFLAGS = -rf

OBJ_DIR = .obj
SRC_DIR = src

SRC_FILES =  transition.ml turing_machine.ml main.ml

OBJ_FILES = $(SRC_FILES:%.ml=%.cmx)
OBJS = $(addprefix $(OBJ_DIR)/, $(OBJ_FILES))

$(OBJ_DIR)/%.cmx: $(SRC_DIR)/%.ml 
	@mkdir -p $(OBJ_DIR)
	$(CML) -I .obj -o $@ -c $<

$(OBJS): $(INTS)

$(NAME): $(OBJS)
	$(CML) -o $(NAME) $(OBJS)

.PHONY: clean
clean:
	$(RM) $(RFLAGS) $(OBJ_DIR)

.PHONY: fclean
fclean: clean
	$(RM) $(RFLAGS) $(NAME)

# Rule to rebuild everything
.PHONY: re
re: fclean all

# Target to build all
.PHONY: all
all: $(NAME)
