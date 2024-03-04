       IDENTIFICATION DIVISION.
       PROGRAM-ID. PLAYER-SPRITE.

       DATA DIVISION.
       FILE SECTION.
       WORKING-STORAGE SECTION.
           77 WINDOW_TITLE PIC X(20) VALUE Z"Player Sprite".
           77 WINDOW_WIDTH USAGE BINARY-INT VALUE 800.
           77 WINDOW_HEIGHT USAGE BINARY-INT VALUE 600.

           77 SDL_INIT_EVERYTHING USAGE BINARY-INT VALUE 62001.
           77 IMG_INIT_PNG USAGE BINARY-INT VALUE 2.
           77 SDL_WINDOWPOS_CENTERED USAGE BINARY-INT VALUE 805240832.

           77 SDL_QUIT USAGE BINARY-INT VALUE 256.
           77 SDL_KEYDOWN USAGE BINARY-INT VALUE 768.
           77 SDL_SCANCODE_ESCAPE USAGE BINARY-INT VALUE 41.
           77 SDL_SCANCODE_SPACE USAGE BINARY-INT VALUE 44.
           77 SDL_SCANCODE_RIGHT USAGE BINARY-INT VALUE 80.
           77 SDL_SCANCODE_LEFT USAGE BINARY-INT VALUE 81.
           77 SDL_SCANCODE_DOWN USAGE BINARY-INT VALUE 82.
           77 SDL_SCANCODE_UP USAGE BINARY-INT VALUE 83.

           77 error-ptr USAGE POINTER VALUE NULL.
           77 sdl-window USAGE POINTER VALUE NULL.
           77 sdl-renderer USAGE POINTER VALUE NULL.
           77 background USAGE POINTER VALUE NULL.
           77 icon-surf USAGE POINTER VALUE NULL.
           77 font-ptr USAGE POINTER VALUE NULL.
           77 text-surface USAGE POINTER VALUE NULL.
           77 text-image USAGE POINTER VALUE NULL.
           77 sprite-image USAGE POINTER VALUE NULL.
           77 keystate-ptr USAGE POINTER VALUE NULL.

           77 playing USAGE BINARY-INT VALUE 1.
           77 return-value USAGE BINARY-INT VALUE 0.

           77 error-message PIC X(50).
           77 error-buff-len USAGE UNSIGNED-INT VALUE 1.
           01 error-buff BASED.
               05 error-buff-arr USAGE
                   BINARY-CHAR UNSIGNED OCCURS 512 TIMES. 

           01 sdl-event.
             05 sdl-event-default.
               10 sdl-event-type USAGE BINARY-INT UNSIGNED.
               10 FILLER USAGE BINARY-CHAR OCCURS 52 TIMES.
             05 keyboard-event REDEFINES sdl-event-default.
               10 keyboard-event-type USAGE BINARY-INT UNSIGNED.
               10 keyboard-event-timestamp USAGE BINARY-INT UNSIGNED.
               10 keyboard-event-windowID USAGE BINARY-INT UNSIGNED.
               10 keyboard-event-state USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-repeat USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-padding2 USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-padding3 USAGE BINARY-CHAR UNSIGNED.
               10 keyboard-event-scancode USAGE BINARY-INT.
               10 keyboard-event-sym USAGE BINARY-INT.
               10 keyboard-event-mod USAGE BINARY-SHORT UNSIGNED.
               10 keyboard-event-unused USAGE BINARY-INT UNSIGNED.

           01 keystate BASED.
               05 keystate-arr USAGE
                   BINARY-CHAR UNSIGNED OCCURS 512 TIMES.

           01 bg-color.
             05 bg-color-r USAGE BINARY-CHAR UNSIGNED VALUE 0.
             05 bg-color-g USAGE BINARY-CHAR UNSIGNED VALUE 0.
             05 bg-color-b USAGE BINARY-CHAR UNSIGNED VALUE 0.
             05 bg-color-a USAGE BINARY-CHAR UNSIGNED VALUE 255.
           
           77 font-size USAGE BINARY-INT VALUE 80.
           01 font-color-struct.
             05 text-color-r USAGE BINARY-CHAR UNSIGNED VALUE 255.
             05 text-color-g USAGE BINARY-CHAR UNSIGNED VALUE 255.
             05 text-color-b USAGE BINARY-CHAR UNSIGNED VALUE 255.
             05 text-color-a USAGE BINARY-CHAR UNSIGNED VALUE 255.
           01 font-color REDEFINES font-color-struct
               USAGE BINARY-INT UNSIGNED.

           77 text-vel USAGE BINARY-INT VALUE 3.
           77 text-xvel USAGE BINARY-INT VALUE 3.
           77 text-yvel USAGE BINARY-INT VALUE 3.
           01 text-rect.
             05 text-rect-x USAGE BINARY-INT VALUE 200.
             05 text-rect-y USAGE BINARY-INT VALUE 0.
             05 text-rect-w USAGE BINARY-INT VALUE 0.
             05 text-rect-h USAGE BINARY-INT VALUE 0.
           
           77 sprite-vel USAGE BINARY-INT VALUE 5.
           01 sprite-rect.
             05 sprite-rect-x USAGE BINARY-INT VALUE 0.
             05 sprite-rect-y USAGE BINARY-INT VALUE 0.
             05 sprite-rect-w USAGE BINARY-INT VALUE 0.
             05 sprite-rect-h USAGE BINARY-INT VALUE 0.

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           PERFORM INITIALIZE-SDL.
           PERFORM LOAD-MEDIA.

           PERFORM UNTIL playing EQUALS 0
               PERFORM CHECK-INPUT
               PERFORM UPDATE-TEXT
               PERFORM UPDATE-SPRITE
               PERFORM DRAW-ALL

               CALL "SDL_Delay" USING
                   BY VALUE 16
               END-CALL

           END-PERFORM.

       INITIALIZE-SDL.
           CALL "SDL_Init" USING
               BY VALUE SDL_INIT_EVERYTHING
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUALS 0 THEN
               MOVE "Error initializing SDL2" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "IMG_Init" USING
               BY VALUE IMG_INIT_PNG
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUAL IMG_INIT_PNG THEN
               MOVE "Error initializing SDL2_image" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "TTF_Init" RETURNING return-value END-CALL.

           IF return-value NOT EQUALS 0 THEN
               MOVE "Error initializing SDL_ttf" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_CreateWindow" USING
               BY CONTENT WINDOW_TITLE
               BY VALUE SDL_WINDOWPOS_CENTERED
               BY VALUE SDL_WINDOWPOS_CENTERED
               BY VALUE WINDOW_WIDTH
               BY VALUE WINDOW_HEIGHT
               BY VALUE 0
               RETURNING sdl-window
           END-CALL.

           IF sdl-window EQUALS NULL THEN
               MOVE "Error creating Window" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_CreateRenderer" USING
               BY VALUE sdl-window
               BY VALUE -1
               BY VALUE 0
               RETURNING sdl-renderer
           END-CALL.

           IF sdl-renderer EQUALS NULL THEN
               MOVE "Error creating Renderer" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "IMG_Load" USING
               BY REFERENCE Z"images/COBOL-logo.png"
               RETURNING icon-surf
           END-CALL.

           IF icon-surf EQUALS NULL THEN
               MOVE "Error loading Surface" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_SetWindowIcon" USING
               BY VALUE sdl-window
               BY VALUE icon-surf
               RETURNING return-value
           END-CALL

           CALL "SDL_GetKeyboardState" USING
               BY REFERENCE NULL
               RETURNING keystate-ptr
           END-CALL.
           SET ADDRESS OF keystate TO keystate-ptr.

           EXIT.

       LOAD-MEDIA.
           CALL "IMG_LoadTexture" USING
               BY VALUE SDL-RENDERER
               BY REFERENCE Z"images/background.png"
               RETURNING background
           END-CALL.

           IF background EQUALS NULL THEN
               MOVE "Error loading Texture" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "TTF_OpenFont" USING
               BY REFERENCE Z"fonts/freesansbold.ttf"
               BY VALUE font-size
               RETURNING font-ptr
           END-CALL.

           IF font-ptr EQUALS NULL THEN
               MOVE "Error creating Font" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "TTF_RenderText_Blended" USING
               BY VALUE font-ptr
               BY REFERENCE Z"COBOL"
               BY VALUE font-color
               RETURNING text-surface
           END-CALL.

           IF text-surface EQUALS NULL THEN
               MOVE "Error creating text Surface" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_CreateTextureFromSurface" USING
               BY VALUE sdl-renderer
               BY VALUE text-surface
               RETURNING text-image
           END-CALL.

           CALL "SDL_FreeSurface" USING
               BY VALUE text-surface
               RETURNING return-value
           END-CALL.
           SET text-surface TO NULL.

           IF text-image EQUALS NULL THEN
               MOVE "Error creating Texture from Surface"
               TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_QueryTexture" USING
               BY VALUE text-image
               BY REFERENCE NULL
               BY REFERENCE NULL
               BY REFERENCE text-rect-w
               BY REFERENCE text-rect-h
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUALS 0 THEN
               MOVE "Error querying Texture" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "IMG_LoadTexture" USING
               BY VALUE SDL-RENDERER
               BY REFERENCE Z"images/COBOL-logo.png"
               RETURNING sprite-image
           END-CALL.

           IF sprite-image EQUALS NULL THEN
               MOVE "Error loading Texture" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           CALL "SDL_QueryTexture" USING
               BY VALUE sprite-image
               BY REFERENCE NULL
               BY REFERENCE NULL
               BY REFERENCE sprite-rect-w
               BY REFERENCE sprite-rect-h
               RETURNING return-value
           END-CALL.

           IF return-value NOT EQUALS 0 THEN
               MOVE "Error querying Texture" TO error-message
               PERFORM PRINT-ERROR
           END-IF.

           EXIT.

       CHECK-INPUT.
           PERFORM WITH TEST AFTER UNTIL return-value EQUALS 0
               CALL "SDL_PollEvent"
                  USING BY REFERENCE sdl-event
                  RETURNING return-value
               END-CALL
               EVALUATE sdl-event-type
                   WHEN SDL_QUIT
                      PERFORM CLEAN-AND-EXIT
                   WHEN SDL_KEYDOWN
                       EVALUATE keyboard-event-scancode
                           WHEN SDL_SCANCODE_ESCAPE
                               PERFORM CLEAN-AND-EXIT
                           WHEN SDL_SCANCODE_SPACE
                               PERFORM CHANGE-COLOR
                      END-EVALUATE
              END-EVALUATE
           END-PERFORM.

           EXIT.

       DRAW-ALL.
           CALL "SDL_RenderClear" USING
               BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL

           CALL "SDL_RenderCopy" USING
               BY VALUE sdl-renderer
               BY VALUE background
               BY REFERENCE NULL
               BY REFERENCE NULL
               RETURNING return-value
           END-CALL.

           CALL "SDL_RenderCopy" USING
               BY VALUE sdl-renderer
               BY VALUE text-image
               BY REFERENCE NULL
               BY REFERENCE text-rect
               RETURNING return-value
           END-CALL.

           CALL "SDL_RenderCopy" USING
               BY VALUE sdl-renderer
               BY VALUE sprite-image
               BY REFERENCE NULL
               BY REFERENCE sprite-rect
               RETURNING return-value
           END-CALL.
           
           CALL "SDL_RenderPresent"
               USING BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL.

           EXIT.

       CHANGE-COLOR.
           COMPUTE bg-color-r = FUNCTION RANDOM * 256 END-COMPUTE.
           COMPUTE bg-color-g = FUNCTION RANDOM * 256 END-COMPUTE.
           COMPUTE bg-color-b = FUNCTION RANDOM * 256 END-COMPUTE.

           CALL "SDL_SetRenderDrawColor" USING
               BY VALUE sdl-renderer
               BY VALUE bg-color-r
               BY VALUE bg-color-g
               BY VALUE bg-color-b
               BY VALUE bg-color-a
               RETURNING return-value
           END-CALL.

           EXIT.
       
       UPDATE-TEXT.
           ADD text-xvel TO text-rect-x END-ADD.
           IF text-xvel IS LESS THAN ZERO THEN
               IF text-rect-x IS LESS THAN ZERO THEN
                   SET text-rect-x TO ZERO
                   SET text-xvel TO text-vel
               END-IF
           ELSE
               IF text-rect-x + text-rect-w IS GREATER THAN
               WINDOW_WIDTH THEN
                   COMPUTE text-rect-x = WINDOW_WIDTH - text-rect-w
                   END-COMPUTE
                   COMPUTE text-xvel = -1 * text-vel END-COMPUTE
               END-IF
           END-IF.

           ADD text-yvel TO text-rect-y END-ADD.
           IF text-yvel IS LESS THAN ZERO THEN
               IF text-rect-y IS LESS THAN ZERO THEN
                   SET text-rect-y TO ZERO
                   SET text-yvel TO text-vel
               END-IF
           ELSE
               IF text-rect-y + text-rect-h IS GREATER THAN
               WINDOW_HEIGHT THEN
                   COMPUTE text-rect-y = WINDOW_HEIGHT - text-rect-h
                   END-COMPUTE
                   COMPUTE text-yvel = -1 * text-vel END-COMPUTE
               END-IF
           END-IF.

           EXIT.

       UPDATE-SPRITE.
           IF keystate-arr(SDL_SCANCODE_DOWN) IS NOT ZERO THEN
               ADD sprite-vel TO sprite-rect-y END-ADD
           END-IF.

           IF keystate-arr(SDL_SCANCODE_UP) IS NOT ZERO THEN
               SUBTRACT sprite-vel FROM sprite-rect-y END-SUBTRACT
           END-IF.

           IF keystate-arr(SDL_SCANCODE_RIGHT) IS NOT ZERO THEN
               ADD sprite-vel TO sprite-rect-x END-ADD
           END-IF.

           IF keystate-arr(SDL_SCANCODE_LEFT) IS NOT ZERO THEN
               SUBTRACT sprite-vel FROM sprite-rect-x END-SUBTRACT
           END-IF.
           
           EXIT.

       PRINT-ERROR.
           CALL "SDL_GetError" 
               RETURNING error-ptr
           END-CALL.
           SET ADDRESS OF error-buff TO error-ptr.
           
           PERFORM VARYING error-buff-len FROM 1 BY 1
               UNTIL error-buff-arr(error-buff-len) = 0
               OR error-buff-len > 512
               CONTINUE
           END-PERFORM.

           DISPLAY FUNCTION TRIM(error-message) ": "
               error-buff(1:error-buff-len) UPON STDERR
           END-DISPLAY.

           PERFORM CLEAN-AND-EXIT.

       CLEAN-AND-EXIT.
           CALL "SDL_DestroyTexture" USING
               BY VALUE sprite-image
               RETURNING return-value
           END-CALL.
           SET sprite-image TO NULL.

           CALL "SDL_DestroyTexture" USING
               BY VALUE text-image
               RETURNING return-value
           END-CALL.
           SET text-image TO NULL.

           CALL "TTF_CloseFont" USING
               BY VALUE font-ptr
               RETURNING return-value
           END-CALL.
           SET font-ptr TO NULL.

           CALL "SDL_DestroyTexture" USING
               BY VALUE background
               RETURNING return-value
           END-CALL.
           SET background TO NULL.

           CALL "SDL_DestroyRenderer" USING
               BY VALUE sdl-renderer
               RETURNING return-value
           END-CALL.
           SET sdl-renderer TO NULL.

           CALL "SDL_DestroyWindow" USING
               BY VALUE sdl-window
               RETURNING return-value
           END-CALL.
           SET sdl-window TO NULL.

           CALL "TTF_Quit"
               RETURNING return-value
           END-CALL.

           CALL "IMG_Quit"
               RETURNING return-value
           END-CALL.

           CALL "SDL_Quit"
               RETURNING return-value
           END-CALL.

           STOP RUN.

       END PROGRAM PLAYER-SPRITE.
