#include <ruby.h>
#include <stdlib.h>

VALUE module_Sudoku;
VALUE class_S4_15;
VALUE class_S3;

/* ############################################ */

typedef struct {
  unsigned char size;
  unsigned char init;
  unsigned char *ptr;
} S4_15;

static int S4_15_alloc_data(S4_15 *this){
  int len;
  
  if (! this->init){
    len = this->size*this->size;
    this->ptr = malloc(len*sizeof(char));
    if (! this->ptr){
      rb_raise(rb_eNoMemError, "Cannot allocate Sudoku data (%d bytes)", len);
      return 0;
    }
    this->init = 1;
  }
  
  return 1;
}

static void S4_15_dealloc(S4_15 *obj){
  if (obj->init)
    free(obj->ptr);
  free(obj);
}

static VALUE S4_15_alloc(VALUE klass){
  S4_15 *ptr = malloc(sizeof(S4_15));
  if (! ptr)
    rb_raise(rb_eNoMemError, "Cannot allocate Sudoku 4_15 struct (%lu bytes)", sizeof(S4_15));
  ptr->size = 0;
  ptr->init = 0;
  return Data_Wrap_Struct(klass, 0, S4_15_dealloc, ptr);
}

static VALUE S4_15_init(VALUE self, VALUE init_base){
  S4_15          *this;
  unsigned int *cursor;
  register int       i;
  int         top, len;
  unsigned char base = NUM2UINT(init_base) & 0xff;
  
  Data_Get_Struct(self, S4_15, this);
  this->size = base*base;
  if (base > 15 || base < 2)
    rb_raise(rb_eArgError, "S4_15 can only handle bases between 2 and 15 (%u not allowed)", base);
  
  S4_15_alloc_data(this);
  
  len = this->size*this->size;
  cursor = (unsigned int *) this->ptr;
  top    = len/(sizeof(int)/sizeof(char));
  for (i=0; i<top; i++)
    cursor[i] = 0;
    
  for (i=top*(sizeof(int)/sizeof(char)); i<len; i++)
    this->ptr[i] = 0;
      
  return self;
}

static VALUE S4_15_initCopy(VALUE copy, VALUE orig){
  S4_15 *this, *parent;
  int len;
  
  Data_Get_Struct(copy, S4_15, this);
  Data_Get_Struct(orig, S4_15, parent);
  
  this->size = parent->size;
  
  S4_15_alloc_data(this);
  memcpy(this->ptr, parent->ptr, parent->size*sizeof(char));
  
  return copy;
}

static VALUE S4_15_get(VALUE self, VALUE col, VALUE row){
  S4_15 *this;
  int x = NUM2INT(col);
  int y = NUM2INT(row);
  
  Data_Get_Struct(self, S4_15, this);
  if (x<0 || x>=this->size || y<0 || y>=this->size)
    rb_raise(rb_eArgError, "Are you sure thre's a %d,%d cell in a %dx%d Sudoku ?", x, y, this->size, this->size);
    
  return INT2NUM(this->ptr[x+y*this->size]);
}

static VALUE S4_15_set(VALUE self, VALUE col, VALUE row, VALUE value){
  S4_15 *this;
  int x = NUM2INT(col);
  int y = NUM2INT(row);
  int v = NUM2INT(value);
  
  Data_Get_Struct(self, S4_15, this);
  if (x<0 || x>=this->size || y<0 || y>=this->size || v<0 || v>this->size)
    rb_raise(rb_eArgError, "%d,%d => %d not allowed in a %dx%d Sudoku", x, y, v, this->size, this->size);
    
  this->ptr[x+y*this->size] = v;
    
  return INT2NUM(v);
}

static VALUE S4_15_each(VALUE self){
  register int i;
  int len;
  S4_15 *this;
  VALUE args;
  
  Data_Get_Struct(self, S4_15, this);
  len = this->size*this->size;
  for (i=0; i<len; i++){
    args = rb_ary_new3(3, INT2FIX(i%this->size), INT2FIX(i/this->size), INT2FIX(this->ptr[i]));
    rb_yield(args);
  }
  
  return self;
}

static VALUE S4_15_size_internal(VALUE self){
  S4_15 *this;
  Data_Get_Struct(self, S4_15, this);
  return INT2FIX(this->size);
}

static void Init_S4_15(VALUE module){
    class_S4_15 = rb_define_class_under(module, "S4_15", rb_cObject);
    rb_define_alloc_func(class_S4_15, S4_15_alloc);
    
    rb_define_const(class_S4_15, "SIZE", INT2FIX(9));
    
    rb_define_method(class_S4_15, "initialize",      S4_15_init, 1);
    rb_define_method(class_S4_15, "initialize_copy", S4_15_initCopy, 1);
    rb_define_method(class_S4_15, "get",             S4_15_get, 2);
    rb_define_method(class_S4_15, "set",             S4_15_set, 3);
    rb_define_method(class_S4_15, "each",            S4_15_each, 0);
    rb_define_method(class_S4_15, "size_internal",   S4_15_size_internal, 0);
}

/* ############################################ */

static void S3_dealloc(void *ptr){
  free(ptr);
}

static VALUE S3_alloc(VALUE klass){
  char *ptr = malloc(41*sizeof(char));
  if (! ptr)
    rb_raise(rb_eNoMemError, "Cannot allocate Sudoku data (%d bytes)", 41);
  return Data_Wrap_Struct(klass, 0, S3_dealloc, ptr);
}

static VALUE S3_init(VALUE self, VALUE dummy){
  unsigned int  *this;
  unsigned char *last;
  register char i;
  
  Data_Get_Struct(self, unsigned int, this);
  for (i=0; i<10; i++)
    this[i] = 0;
  last = (char *) &(this[10]);
  *last =0xf; /* 0x0f => 4 derniers bits pas dans le sudoku */
    
  return self;
}

static VALUE S3_initCopy(VALUE copy, VALUE orig){
  unsigned char *this, *parent;
  char i;
  
  Data_Get_Struct(copy, unsigned char, this);
  Data_Get_Struct(orig, unsigned char, parent);
  if (this == parent)
    return copy;
  
  memcpy(this, parent, 41*sizeof(char));
    
  return copy;
}

static VALUE S3_get(VALUE self, VALUE col, VALUE row){
  unsigned char *this, x, y, i;
  
  Data_Get_Struct(self, unsigned char, this);
  x = NUM2UINT(col)&0xff;
  y = NUM2UINT(row)&0xff;
  
  if (x>=9 || y>=9)
    rb_raise(rb_eArgError, "Are you sure thre's a %d,%d cell in a 9x9 Sudoku ?", x, y);
  
  i = x + y*9;  
  if (i%2 == 0)
    return INT2FIX((this[i/2] >> 4) & 0x0f);
  else
    return INT2FIX(this[i/2] & 0x0f);
}

static VALUE S3_set(VALUE self, VALUE col, VALUE row, VALUE value){
  unsigned char *this, x, y, i, val;
  
  Data_Get_Struct(self, unsigned char, this);
  x   = NUM2UINT(col)&0x0f;
  y   = NUM2UINT(row)&0x0f;
  val = NUM2UINT(value)&0x0f;
  
  
  if (x>=9 || y>=9 || val > 9)
    rb_raise(rb_eArgError, "%d,%d => %d not allowed in a 9x9 Sudoku", x, y, val);
    
  i = x + y*9;
  if (i%2 == 0)
    this[i/2] = (this[i/2]&0x0f) | (val<<4);
  else
    this[i/2] = (this[i/2]&0xf0) | val;
    
  return INT2FIX(val);
}

static VALUE S3_each(VALUE self){
  char x=0, y=0, i, val;
  unsigned char *this;
  VALUE args;
  
  Data_Get_Struct(self, unsigned char, this);
  for (i=0; i<81; i++){
    val = (i%2 == 0) ? ((this[i/2] >> 4) & 0x0f) : (this[i/2] & 0x0f);
    args = rb_ary_new3(3, INT2FIX(x), INT2FIX(y), INT2FIX(val));
    rb_yield(args);
    if (x<8)
      x++;
    else {
      y++;
      x = 0;
    }
  }
  
  return self;
}

static VALUE S3_isComplete(VALUE self){
  char i, val;
  unsigned char *this;
  
  Data_Get_Struct(self, unsigned char, this);
  for (i=0; i<41; i++)
    if ((this[i]&0xf0) == 0 || (this[i]&0x0f) == 0)
      return Qfalse;
  
  return Qtrue;
}

static VALUE S3_dump(VALUE self){
  char string[83] = {'\0'};
  int i;
  unsigned char *data;
  
  Data_Get_Struct(self, unsigned char, data);
  for (i=0; i<41; i++)
    sprintf(&(string[2*i]), "%X", data[i]);

  return rb_str_new(string, 82);
}

static void Init_S3(VALUE module){
    class_S3 = rb_define_class_under(module, "S3", rb_cObject);
    rb_define_alloc_func(class_S3, S3_alloc);
    
    rb_define_const(class_S3, "SIZE", INT2FIX(9));
    
    rb_define_method(class_S3, "__initialize", S3_init, 1);
    rb_define_method(class_S3, "initialize_copy", S3_initCopy, 1);
    rb_define_method(class_S3, "get", S3_get, 2);
    rb_define_method(class_S3, "set", S3_set, 3);
    rb_define_method(class_S3, "each", S3_each, 0);
    rb_define_method(class_S3, "complete?", S3_isComplete, 0);
    rb_define_method(class_S3, "dump", S3_dump, 0);
}

/* ############################################ */

void Init_sudokucore(){
  module_Sudoku = rb_define_module("Sudoku");
  Init_S3(module_Sudoku);
  Init_S4_15(module_Sudoku);
}
