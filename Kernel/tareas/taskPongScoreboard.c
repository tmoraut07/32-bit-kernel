#include "task_lib.h"

#define WIDTH TASK_VIEWPORT_WIDTH
#define HEIGHT TASK_VIEWPORT_HEIGHT

#define SHARED_SCORE_BASE_VADDR (PAGE_ON_DEMAND_BASE_VADDR + 0xF00)
#define CANT_PONGS 3


void task(void) {
	screen pantalla;
	// ¿Una tarea debe terminar en nuestro sistema?
	while (true)
	{
	// Completar:
	// - Pueden definir funciones auxiliares para imprimir en pantalla
	// - Pueden usar `task_print`, `task_print_dec`, etc. 
		uint32_t* task_records = (uint32_t*) SHARED_SCORE_BASE_VADDR;
		for (int i = 0; i < CANT_PONGS; i++) {
			uint32_t y = 2 + i*2;
			task_print(pantalla, "Pong ", 2, y, C_FG_WHITE);
			task_print_dec(pantalla, i, 1, 7, y, C_FG_WHITE);
			task_print(pantalla, ":", 8, y, C_FG_WHITE);

			task_print_dec(pantalla, task_records[4*2*i], 2, 10, y, C_FG_CYAN);
			task_print_dec(pantalla, task_records[4*2*i+1], 2, 14, y, C_FG_MAGENTA);
		}
		syscall_draw(pantalla);
	}
}
