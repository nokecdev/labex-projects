import pygame
import random

pygame.init()

#Size of the window
WIDTH = 800
HEIGHT = 600
FPS = 10
#Define colors
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)
GREEN = (0, 255, 0)
RED = (255, 0, 0)
BLUE = (0, 0, 255)
YELLOW = (255, 255, 0)
BACKGROUND_COLOR = (50, 50, 50)

screen = pygame.display.set_mode((WIDTH, HEIGHT))
pygame.display.set_caption("Snake Game") # Title of the window
clock = pygame.time.Clock() # Track time of the game

snake_block_size = 20
snake_speed = 5 # moves 5 pixels

#Scores
font_style = pygame.font.SysFont(None, 50)
score_font = pygame.font.SysFont(None, 35)

#Size of power up
powerup_block_size = 20

#-----------Functions-----------

def draw_snake(snake_block_size, snake_list):
    for x in snake_list:
        pygame.draw.rect(
            screen, GREEN, [x[0], x[1], snake_block_size, snake_block_size]
        )

def draw_powerup(powerup_x, powerup_y):
    pygame.draw.rect(
        screen, RED, [powerup_x, powerup_y, powerup_block_size, powerup_block_size]
    )

def display_score(score):
    value = score_font.render("Score: " + str(score), True, WHITE)
    screen.blit(value, [10, 10])

#----------- Main function-----------
def game_loop():
    game_over = False
    game_close = False

    # Set up the snake's starting position
    x1 = WIDTH / 2
    y1 = HEIGHT / 2
    x1_change = 0
    y1_change = 0

    # Set up the snake's body
    snake_list = []
    snake_length = 1

    # Set up the power-up
    powerup_x = round(random.randrange(0, WIDTH - powerup_block_size) / 20) * 20
    powerup_y = round(random.randrange(0, HEIGHT - powerup_block_size) / 20) * 20

    # Set up the game loop
    while not game_over:
        while game_close:
            screen.fill(BACKGROUND_COLOR)
            message = font_style.render("Press SPACE to play again", True, YELLOW)
            screen.blit(message, [WIDTH / 2 - 200, HEIGHT / 2 - 50])
            pygame.display.flip()

            for event in pygame.event.get():
                if event.type == pygame.QUIT:
                    game_over = True
                    game_close = False
                if event.type == pygame.KEYDOWN:
                    if event.key == pygame.K_SPACE:
                        game_loop()

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                game_over = True
            if event.type == pygame.KEYDOWN:
                if event.key == pygame.K_LEFT:
                    x1_change = -snake_block_size
                    y1_change = 0
                elif event.key == pygame.K_RIGHT:
                    x1_change = snake_block_size
                    y1_change = 0
                elif event.key == pygame.K_UP:
                    y1_change = -snake_block_size
                    x1_change = 0
                elif event.key == pygame.K_DOWN:
                    y1_change = snake_block_size
                    x1_change = 0

        if x1 >= WIDTH or x1 < 0 or y1 >= HEIGHT or y1 < 0:
            game_close = True

        x1 += x1_change
        y1 += y1_change
        screen.fill(BACKGROUND_COLOR)
        pygame.draw.rect(
            screen, BLUE, [powerup_x, powerup_y, powerup_block_size, powerup_block_size]
        )

        snake_head = []
        snake_head.append(x1)
        snake_head.append(y1)
        snake_list.append(snake_head)
        if len(snake_list) > snake_length:
            del snake_list[0]

        for x in snake_list[:-1]:
            if x == snake_head:
                game_close = True

        draw_snake(snake_block_size, snake_list)
        display_score(snake_length - 1)

        pygame.display.flip()

        if x1 == powerup_x and y1 == powerup_y:
            powerup_x = round(random.randrange(0, WIDTH - powerup_block_size) / 20) * 20
            powerup_y = (
                round(random.randrange(0, HEIGHT - powerup_block_size) / 20) * 20
            )
            snake_length += 1

        clock.tick(snake_speed)

    pygame.quit()