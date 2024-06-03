NAME = ft_turing

CML = ocamlc
CFLAGS = 

RM = rm
RFLAGS = -rf

OBJ_DIR = .obj
OBJ_FILES = $(SRC_FILES:.ml=.cmo)
OBJS = $(addprefix $(OBJ_DIR)/, $(OBJ_FILES))

INT_FILES = $(SRC_FILES:.ml=.cmi)
INTS = $(addprefix $(OBJ_DIR)/, $(INT_FILES))

SRC_DIR = src
SRC_FILES = main.ml
SRCS = $(addprefix $(SRC_DIR)/, $(SRC_FILES))

$(OBJ_DIR)/%.cmo: $(SRC_DIR)/%.ml
	@mkdir -p $(OBJ_DIR)
	$(CML) -o $@ -c $<

.PHONY: all
all: $(NAME)

$(NAME): $(OBJS)
	$(CML) -o $(NAME) $(OBJS)

.PHONY: clean
clean:
	$(RM) $(RFLAGS) $(OBJS) $(INTS)
	$(RM) $(RFLAGS) $(OBJ_DIR)

.PHONY: fclean
fclean: clean
	$(RM) $(RFLAGS) $(NAME)

.PHONY: re
re: fclean all
