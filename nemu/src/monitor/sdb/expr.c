/***************************************************************************************
* Copyright (c) 2014-2022 Zihao Yu, Nanjing University
*
* NEMU is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
*
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
*
* See the Mulan PSL v2 for more details.
***************************************************************************************/

#include <isa.h>
#include <stdio.h>
#include <string.h>

/* We use the POSIX regex functions to process regular expressions.
 * Type 'man regex' for more information about POSIX regex functions.
 */
#include <regex.h>

// TK_EQ = 256 + 1
enum {
  TK_NOTYPE = 256, 
  TK_EQ, 
  TK_NUM
};

static struct rule {
  const char *regex;
  int token_type;
} rules[] = {

  /* TODO: Add more rules.
   * Pay attention to the precedence level of different rules.
   */
  {"\\(", '('},
  {"\\)", ')'},
  {"[0-9]+",    TK_NUM}, // num
  {"\\*", '*'},          // mul
  {"/",   '/'},          // div
  {" +",  TK_NOTYPE},    // spaces
  {"\\+", '+'},          // plus
  {"\\-", '-'},          // sub
  // {"==",   TK_EQ},    // equal
};

#define NR_REGEX ARRLEN(rules)

static regex_t re[NR_REGEX] = {};

/* Rules are used for many times.
 * Therefore we compile them only once before any usage.
 */
void init_regex() {
  int i;
  char error_msg[128];
  int ret;

  for (i = 0; i < NR_REGEX; i ++) {
    ret = regcomp(&re[i], rules[i].regex, REG_EXTENDED);
    if (ret != 0) {
      regerror(ret, &re[i], error_msg, 128);
      panic("regex compilation failed: %s\n%s", error_msg, rules[i].regex);
    }
  }
}

typedef struct token {
  int type;
  char str[32];
} Token;

static Token tokens[32] __attribute__((used)) = {};
static int nr_token __attribute__((used))  = 0;

static bool make_token(char *e) {
  int position = 0;
  int i;
  regmatch_t pmatch;

  nr_token = 0;

  while (e[position] != '\0') {
    /* Try all rules one by one. */
    for (i = 0; i < NR_REGEX; i ++) {
      if (regexec(&re[i], e + position, 1, &pmatch, 0) == 0 && pmatch.rm_so == 0) {
        char *substr_start = e + position;
        int substr_len = pmatch.rm_eo;

        Log("match rules[%d] = \"%s\" at position %d with len %d: %.*s",
            i, rules[i].regex, position, substr_len, substr_len, substr_start);

        position += substr_len;

        /* TODO: Now a new token is recognized with rules[i]. Add codes
         * to record the token in the array `tokens'. For certain types
         * of tokens, some extra actions should be performed.
         */
   
        switch(rules[i].token_type) {
          case(TK_NOTYPE): break;
          case(TK_NUM):
            assert(substr_len <= 32);
            memcpy(tokens[nr_token].str, substr_start, substr_len);
          default: 
            tokens[nr_token++].type = rules[i].token_type; 
        }
        
        break;
      }
    }

    if (i == NR_REGEX) {
      printf("no match at position %d\n%s\n%*.s^\n", position, e, position, "");
      return false;
    }
  }

  return true;
}


// for eval

// 检查是否是合法的括号
bool check_legal(int p, int q) {
  int cnt = 0;
  
  for(int i = p; i <= q; i++) {
    int type = tokens[i].type;
    if(type == '(') {
      cnt++;
    } else if(type == ')') {
      if(cnt == 0) {
        return false;
      } else{
        cnt--;
      }
    }
  }

  return (cnt == 0);
}

bool check_parentheses(int p, int q) {
  return check_legal(p, q) && tokens[p].type == '(' && tokens[q].type == ')' && check_legal(p + 1, q - 1);
}

int priority[256];

void init_priority() {
  priority['+'] = 1;
  priority['-'] = 1;  
  priority['*'] = 2;
  priority['/'] = 2;
}


word_t eval(int p, int q) {
 return 0; 
}


word_t expr(char *e, bool *success) {
  if (!make_token(e)) {
    *success = false;
    return 0;
  }

  /* TODO: Insert codes to evaluate the expression. */
  for(int i = 0; i < nr_token; i++) {
    if(tokens[i].type == TK_NUM) {
      printf("%s ", tokens[i].str);
    } else {
      printf("%c ", tokens[i].type);
    }
  }
  printf("\n");

  if(check_parentheses(0, nr_token - 1))
    printf("test pass\n");
  else
    printf("test fail\n");


  return 0;
}
