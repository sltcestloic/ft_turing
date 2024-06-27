NAME = ft_turing

CML = ocamlfind ocamlopt -package yojson -linkpkg
CFLAGS = 

RM = rm
RFLAGS = -rf

OBJ_DIR = .obj
SRC_DIR = src

SRC_FILES = transition.ml turing_machine.ml parser.ml runner.ml main.ml

OBJ_FILES = $(SRC_FILES:%.ml=%.cmx)
OBJS = $(addprefix $(OBJ_DIR)/, $(OBJ_FILES))

$(OBJ_DIR)/%.cmx: $(SRC_DIR)/%.ml 
	@mkdir -p $(OBJ_DIR)
	$(CML) -I .obj -o $@ -c $<

$(NAME): $(OBJS)
	$(CML) -o $(NAME) $(OBJS)

.PHONY: clean
clean:
	$(RM) $(RFLAGS) $(OBJ_DIR)

.PHONY: fclean
fclean: clean
	$(RM) $(RFLAGS) $(NAME)

.PHONY: re
re: fclean all

.PHONY: all
all: $(NAME)
