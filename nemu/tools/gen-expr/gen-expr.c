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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <assert.h>
#include <string.h>

// this should be enough
static char buf[65536] = {};
static char code_buf[65536 + 128] = {}; // a little larger than `buf`
static char *code_format =
"#include <stdio.h>\n"
"int main() { "
"  unsigned result = %s; "
"  printf(\"%%u\", result); "
"  return 0; "
"}";

static int buf_idx = 0;

// generate a random number less than n
static uint32_t choose(uint32_t n) {
  return ((uint32_t)rand()) % n;
}

static void gen_num() {
  uint32_t rand_num = choose(100);
  int i = buf_idx;
  // printf("random num = %d\n", rand_num);
  rand_num = (rand_num == 0 ? 1 : rand_num);
  while(rand_num != 0) {
    buf[buf_idx++] = (rand_num % 10) + '0';
    rand_num = rand_num / 10;
  }
  int j = buf_idx - 1;
  // reverse num
  while(i < j) {
    char t = buf[i];
    buf[i] = buf[j];
    buf[j] = t;
    i++; j--;
  }
}

static void gen(char c) {
  buf[buf_idx++] = c;
}

static void gen_op() {
  switch(choose(4)) {
    case 0: gen('+'); break;
    case 1: gen('-'); break;
    case 2: gen('*'); break;
    default: gen('/'); break;
  }
}

static void gen_rand_expr() {
  switch(choose(3)) {
    case 0: gen_num(); break;
    case 1: gen('('); gen_rand_expr(); gen(')'); break;
    default: gen_rand_expr(); gen_op(); gen_rand_expr(); break;
  }
  buf[buf_idx] = '\0';
}

int main(int argc, char *argv[]) {
  int seed = time(0);

  srand(seed);
  int loop = 1;
  if (argc > 1) {
    sscanf(argv[1], "%d", &loop);
  }
  int i;
  for (i = 0; i < loop; i ++) {
    buf_idx = 0;
    gen_rand_expr();
    sprintf(code_buf, code_format, buf);
    FILE *fp = fopen("/tmp/.code.c", "w");
    assert(fp != NULL);
    fputs(code_buf, fp);
    fclose(fp);

    // exec the gen code
    int ret = system("gcc /tmp/.code.c -o /tmp/.expr");
    if (ret != 0) continue;

    fp = popen("/tmp/.expr", "r");
    assert(fp != NULL);

    int result;
    ret = fscanf(fp, "%d", &result);
    pclose(fp);

    printf("%u %s\n", result, buf);
  }
  return 0;
}
