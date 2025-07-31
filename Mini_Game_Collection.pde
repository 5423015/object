interface Game {
  void initialize();      // 初期化処理
  void update();          // ゲーム状態更新
  void drawGame();        // 描画シーンを切り替える統括メソッド

  void drawTitle();       // タイトル画面描画
  void drawScoreBoard();  // スコアの描画
  void drawGameScene();   // ゲーム中の描画
  void drawWin();         // 勝利画面描画
  void drawLose();        // 敗北画面描画
  void drawBack();        // 裏設定画面描画

  void keyPressed();      // キー入力処理
  void mousePressed();    // マウス入力処理

  void resetGame();       // ゲームリセット
}

// シューティングゲームのクラス
class ShootingGame implements Game {
  final int TARGET_HITS = 5;
  final int PLAYER_HITS_ALLOWED = 5;
  final int PLAYER_BAR_WIDTH = 20, PLAYER_BAR_HEIGHT = 100;
  final int ENEMY_BAR_WIDTH = 10, ENEMY_BAR_HEIGHT = 60;
  final int BULLET_SIZE = 15;

  int scene = 0;
  float playerBarY, enemyBarY;
  int enemyFireInterval = 600, lastEnemyFireTime = 0;
  int playerFireInterval = 400, lastPlayerFireTime = 0;
  float enemySpeed = 3;
  int enemyDirection = 1;
  ArrayList<Bullet> enemyBullets = new ArrayList<>();
  ArrayList<Bullet> playerBullets = new ArrayList<>();
  int playerHitCount = 0, enemyHitCount = 0;
  int winStreak = 0;
  PFont font;

  public void initialize() {
    font = createFont("ＭＳ Ｐゴシック", 50);
    textFont(font);
    playerBarY = height / 2;
    enemyBarY = height / 2;
  }

  public void update() {
    if (scene == 1) {
      playerBarY = constrain(mouseY, PLAYER_BAR_HEIGHT/2, height - PLAYER_BAR_HEIGHT/2);
      enemyBarY += enemySpeed * enemyDirection;
      if (enemyBarY > height - ENEMY_BAR_HEIGHT/2 || enemyBarY < ENEMY_BAR_HEIGHT/2) {
        enemyDirection *= -1;
      }
      if (millis() - lastEnemyFireTime > enemyFireInterval) {
        enemyFire();
        lastEnemyFireTime = millis();
      }
      for (int i = enemyBullets.size() -1; i >= 0; i--) {
        Bullet b = enemyBullets.get(i);
        b.x += b.speedX;
        b.y += b.speedY;
        if (b.y < BULLET_SIZE/2 || b.y > height - BULLET_SIZE/2) {
          b.speedY *= -1;
        }
        if (b.x < -BULLET_SIZE) {
          enemyBullets.remove(i);
        } else if (checkCollision(playerBarX(), playerBarY, PLAYER_BAR_WIDTH, PLAYER_BAR_HEIGHT, b.x, b.y, BULLET_SIZE)) {
          playerHitCount++;
          if (playerHitCount >= PLAYER_HITS_ALLOWED) {
            scene = 3;
            winStreak = 0;
          }
          enemyBullets.remove(i);
        }
      }
      for (int i = playerBullets.size() -1; i >= 0; i--) {
        Bullet b = playerBullets.get(i);
        b.x += b.speedX;
        b.y += b.speedY;
        if (b.x > width + BULLET_SIZE) {
          playerBullets.remove(i);
        } else if (checkCollision(enemyBarX(), enemyBarY, ENEMY_BAR_WIDTH, ENEMY_BAR_HEIGHT, b.x, b.y, BULLET_SIZE)) {
          enemyHitCount++;
          playerBullets.remove(i);
          if (enemyHitCount >= TARGET_HITS) {
            winStreak++;
            if (winStreak >= 3) {
              scene = 4;
            } else {
              scene = 2;
            }
          }
        }
      }
    }
  }

  public void drawGame() {
    background(0);
    switch (scene) {
    case 0:
      drawTitle();
      break;
    case 1:
      drawGameScene();
      break;
    case 2:
      drawWin();
      break;
    case 3:
      drawLose();
      break;
    case 4:
      drawBack();
      break;
    }
  }

  public void drawTitle() {
    fill(255);
    textAlign(CENTER, CENTER);
    fill(0, 255, 255);
    textSize(100);
    text("シューティングゲーム", width / 2, height / 4 - 100);
    fill(255);
    textSize(30);
    textLeading(60);
    text("スペースキーで弾を撃とう！\n"
      + "敵のバーに弾を5回当てると勝ちになります。\n"
      + "ただし、弾が自分のバーに5回当たると負けです。\n"
      + "敵のバーは自動で動き、三方向に弾を撃ってきます。\n"
      + "弾は上下の壁に当たると跳ね返りますが、左右では跳ね返りません。\n"
      + "バーはマウスで上下に動かせます。素早く反応しよう！",
      width / 2, height / 2);
    fill(255, 0, 0);
    textSize(30);
    text("ENTERキーでゲームスタート", width / 2, height * 0.85f);
  }

  public void drawGameScene() {
    fill(255, 0, 0);
    rectMode(CENTER);
    rect(playerBarX(), playerBarY, PLAYER_BAR_WIDTH, PLAYER_BAR_HEIGHT);
    fill(0, 255, 0);
    rect(enemyBarX(), enemyBarY, ENEMY_BAR_WIDTH, ENEMY_BAR_HEIGHT);
    fill(255, 100, 100);
    for (Bullet b : playerBullets) ellipse(b.x, b.y, BULLET_SIZE, BULLET_SIZE);
    fill(100, 100, 255);
    for (Bullet b : enemyBullets) ellipse(b.x, b.y, BULLET_SIZE, BULLET_SIZE);
    drawScoreBoard();
  }

  public void drawWin() {
    fill(255, 255, 0);
    textAlign(CENTER, CENTER);
    textSize(70);
    text("You WIN!", width/2, height/2);
    textSize(30);
    text("クリックでリスタート", width/2, height/2 + 50);
  }

  public void drawLose() {
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(70);
    text("You LOSE!", width/2, height/2);
    textSize(30);
    text("クリックでリスタート", width/2, height/2 + 50);
  }

  public void drawBack() {
    textAlign(CENTER, CENTER);
    textSize(50);
    fill(255, 255, 0);
    text("敵に負けずに " + winStreak + " 連勝おめでとう！", width / 2, height / 2 - 60);
    text("遊びすぎて目が疲れないように休憩しっかりとろう！", width / 2, height / 2 + 20);
  }

  public void drawScoreBoard() {
    fill(255);
    textAlign(LEFT, TOP);
    textSize(20);
    text("敵に当てた回数: " + enemyHitCount + " / " + TARGET_HITS, 10, 10);
    text("自分が当たった回数: " + playerHitCount + " / " + PLAYER_HITS_ALLOWED, 10, 40);
  }

  public void keyPressed() {
    if (scene == 0 && (key == ENTER || key == RETURN)) {
      scene = 1;
      resetGame();
    } else if ((scene == 2 || scene == 3) && key == CODED && keyCode == TAB) {
      scene = 0;
    } else if (scene == 1 && key == ' ') {
      if (millis() - lastPlayerFireTime > playerFireInterval) {
        playerFire();
        lastPlayerFireTime = millis();
      }
    }
  }

  public void mousePressed() {
    if (scene == 2 || scene == 3) {
      resetGame();
      scene = 0;
    }
  }

  public void resetGame() {
    playerHitCount = 0;
    enemyHitCount = 0;
    playerBullets.clear();
    enemyBullets.clear();
  }

  void playerFire() {
    playerBullets.add(new Bullet(playerBarX() - PLAYER_BAR_WIDTH/2 - BULLET_SIZE/2, playerBarY, -7, 0));
  }

  void enemyFire() {
    float ex = enemyBarX() + ENEMY_BAR_WIDTH/2 + BULLET_SIZE/2;
    float ey = enemyBarY;
    enemyBullets.add(new Bullet(ex, ey, 7, 0));
    enemyBullets.add(new Bullet(ex, ey, 5, -3));
    enemyBullets.add(new Bullet(ex, ey, 5, 3));
  }

  float playerBarX() {
    return width - 50;
  }

  float enemyBarX() {
    return 50;
  }

  boolean checkCollision(float rx, float ry, float rw, float rh, float bx, float by, float bSize) {
    float closestX = constrain(bx, rx - rw/2, rx + rw/2);
    float closestY = constrain(by, ry - rh/2, ry + rh/2);
    float dx = bx - closestX;
    float dy = by - closestY;
    return dx*dx + dy*dy < (bSize/2)*(bSize/2);
  }

  class Bullet {
    float x, y, speedX, speedY;
    Bullet(float x, float y, float sx, float sy) {
      this.x = x;
      this.y = y;
      this.speedX = sx;
      this.speedY = sy;
    }
  }
}

// エアホッケーゲームのクラス
class AirHockeyGame implements Game {
  final int BACK_WIN_COUNT = 3;
  final int BALL_DIAMETER = 30;
  final int RACKET_WIDTH = 5;
  final int RACKET_HEIGHT = 100;
  final int ENEMY_X = 200;
  final int ENEMY_POST_WIDTH = 30;
  final int ENEMY_POST_HEIGHT = 250;
  final int TARGET_SCORE = 3;

  int scene = 0;
  float ballX, ballY;
  float xSpeed, ySpeed;
  float enemyY;
  int myScore = 0, enemyScore = 0;
  int myWin = 0, enemyWin = 0;
  final int SCORE_LABEL_Y = 30;
  final int SCORE_VALUE_Y = 70;
  PFont font;

  public void initialize() {
    rectMode(CORNER);
    textAlign(LEFT, BASELINE);
    font = createFont("ＭＳ Ｐゴシック", 50);
    textFont(font);
    resetBall();
  }

  public void update() {
    if (scene != 1) return;

    ballX += xSpeed;
    ballY += ySpeed;

    if (abs(xSpeed) > 40 || abs(ySpeed) > 40) {
      xSpeed = 10 * (xSpeed > 0 ? 1 : -1);
      ySpeed = 13 * (ySpeed > 0 ? 1 : -1);
    }

    if (ballY - BALL_DIAMETER / 2 < 0 || ballY + BALL_DIAMETER / 2 > height) {
      ySpeed *= -random(0.8, 2);
    }

    if (checkCollision(width - ENEMY_X, mouseY, RACKET_WIDTH, RACKET_HEIGHT, ballX, ballY)) {
      xSpeed *= -random(0.8, 2);
    }

    if (checkCollision(ENEMY_X, enemyY, RACKET_WIDTH, RACKET_HEIGHT, ballX, ballY)) {
      xSpeed *= -random(0.8, 2);
    }

    if (checkCollision(0, 0, ENEMY_POST_WIDTH, ENEMY_POST_HEIGHT, ballX, ballY) ||
      checkCollision(0, height - ENEMY_POST_HEIGHT, ENEMY_POST_WIDTH, ENEMY_POST_HEIGHT, ballX, ballY)) {
      xSpeed *= -random(0.8, 2);
    }

    if (myScore < TARGET_SCORE && enemyScore < TARGET_SCORE) {
      if (ballX - BALL_DIAMETER / 2 < 0) {
        myScore++;
        resetBall();
        xSpeed *= -1;
      } else if (ballX + BALL_DIAMETER / 2 > width) {
        enemyScore++;
        resetBall();
      }
    }

    if (enemyScore >= TARGET_SCORE) {
      enemyWin++;
      scene = 3;
    } else if (myScore >= TARGET_SCORE) {
      myWin++;
      scene = 2;
    }

    if (ballX > 200) {
      enemyY += (ballY - enemyY) * 0.1;
    } else {
      enemyY = -RACKET_HEIGHT;
    }
  }

  public void drawGame() {
    background(0);
    switch (scene) {
    case 0:
      drawTitle();
      break;
    case 1:
      drawGameScene();
      break;
    case 2:
      drawWin();
      break;
    case 3:
      drawLose();
      break;
    case 4:
      drawBack();
      break;
    }
  }

  public void drawTitle() {
    textAlign(LEFT, BOTTOM);
    fill(0, 255, 255);
    textSize(70);
    text("Air hockey with unpredictable bounces", width / 20, height / 6 - 50);
    fill(255, 0, 0);
    textSize(55);
    text("enterを押してゲームスタート", width / 4, height / 2 - 225);
    fill(255);
    textSize(40);
    text("勝利条件：相手より先に target score へ到達すること", width / 16, height / 2 - 150);
    text("ボールが紫色のラインを越えたら得点です", width / 16, height / 2 - 50);
    text("遊び方: mouse を上下に動かして赤いラケットでボールを跳ね返す", width / 16, height / 2 + 50);
    text("ボールは青色、自分のラケットは赤色、敵のラケットは緑色", width / 16, height / 2 + 150);
    text("注意点：しっかりラケットの左側でボールを返そう", width / 16, height / 2 + 250);
    text("mouse のカーソルは黒い画面上にないとラケットが動かない", width / 16, height / 2 + 350);
  }

  public void drawGameScene() {
    strokeWeight(3);
    stroke(255, 100);
    line(width / 2, 0, width / 2, height);

    strokeWeight(10);
    stroke(255, 0, 255);
    line(5, 0, 5, height);
    line(width - 5, 0, width - 5, height);
    noStroke();

    fill(255, 0, 0);
    rect(width - ENEMY_X, mouseY - RACKET_HEIGHT / 2, RACKET_WIDTH, RACKET_HEIGHT);

    fill(0, 255, 0);
    rect(ENEMY_X, enemyY - RACKET_HEIGHT / 2, RACKET_WIDTH, RACKET_HEIGHT);

    rect(0, 0, ENEMY_POST_WIDTH, ENEMY_POST_HEIGHT);
    rect(0, height - ENEMY_POST_HEIGHT, ENEMY_POST_WIDTH, ENEMY_POST_HEIGHT);

    fill(0, 0, 255);
    ellipse(ballX, ballY, BALL_DIAMETER, BALL_DIAMETER);

    drawScoreBoard();
  }


  public void drawScoreBoard() {
    textAlign(CENTER, CENTER);
    fill(255, 105, 180);
    textSize(30);
    text("enemyTarget", width / 2 - 500, SCORE_LABEL_Y);
    text("enemyScore", width / 2 - 300, SCORE_LABEL_Y);
    text("enemyWin", width / 2 - 100, SCORE_LABEL_Y);
    text("myTarget", width / 2 + 100, SCORE_LABEL_Y);
    text("myScore", width / 2 + 300, SCORE_LABEL_Y);
    text("myWin", width / 2 + 500, SCORE_LABEL_Y);
    text(TARGET_SCORE, width / 2 - 500, SCORE_VALUE_Y);
    text(enemyScore, width / 2 - 300, SCORE_VALUE_Y);
    text(enemyWin, width / 2 - 100, SCORE_VALUE_Y);
    text(TARGET_SCORE, width / 2 + 100, SCORE_VALUE_Y);
    text(myScore, width / 2 + 300, SCORE_VALUE_Y);
    text(myWin, width / 2 + 500, SCORE_VALUE_Y);
  }

  public void drawWin() {
    fill(255, 255, 0);
    textAlign(CENTER, CENTER);
    textSize(70);
    text("You WIN!", width/2, height/2);
    textSize(30);
    text("クリックでリスタート", width/2, height/2 + 50);
  }

  public void drawLose() {
    fill(255, 0, 0);
    textAlign(CENTER, CENTER);
    textSize(70);
    text("You LOSE!", width/2, height/2);
    textSize(30);
    text("クリックでリスタート", width/2, height/2 + 50);
  }

  public void drawBack() {
    textAlign(CENTER, CENTER);
    textSize(50);
    fill(255, 255, 0);
    text("敵に負けずに " + BACK_WIN_COUNT + " 連勝おめでとう！", width / 2, height / 2 - 60);
    text("遊びすぎて目が疲れないように休憩しっかりとろう！", width / 2, height / 2 + 20);
  }

  public void keyPressed() {
    if (scene == 0 && (key == ENTER || key == RETURN)) {
      scene = 1;
    } else if (scene == 4 && key == TAB) {
      scene = 0;
    }
  }

  public void mousePressed() {
    if (scene == 2 || scene == 3) {
      if (scene == 2 && myWin == BACK_WIN_COUNT && enemyWin == 0) {
        myWin = 0;
        enemyWin = 0;
        scene = 4;
      } else {
        scene = 1;
      }
      myScore = 0;
      enemyScore = 0;
      resetBall();
    }
  }

  public void resetGame() {
    myScore = 0;
    enemyScore = 0;
    resetBall();
  }

  void resetBall() {
    ballX = width / 2;
    ballY = height / 2;
    xSpeed = random(3, 7) * (random(1) < 0.5 ? 1 : -1);
    ySpeed = random(3, 7) * (random(1) < 0.5 ? 1 : -1);
  }

  boolean checkCollision(float rx, float ry, float rw, float rh, float bx, float by) {
    return bx + BALL_DIAMETER / 2 > rx &&
      bx - BALL_DIAMETER / 2 < rx + rw &&
      by + BALL_DIAMETER / 2 > ry - rh / 2 &&
      by - BALL_DIAMETER / 2 < ry + rh / 2;
  }
}

// ゲーム選択クラス
class GameSelector {
  Game currentGame = null;
  String[] gameNames = {"Shooting Game", "Air hockey with unpredictable bounce"};
  int selectedIndex = 0;
  boolean inMenu = true;
  void update() {
    if (!inMenu && currentGame != null) {
      currentGame.update();
    }
  }

  void drawGame() {
    if (inMenu) {
      background(50);
      fill(0, 255, 255);
      textSize(60);
      textAlign(CENTER, CENTER);
      text("Select a Game", width/2, 100);
      for (int i = 0; i < gameNames.length; i++) {
        if (i == selectedIndex) fill(255, 0, 0);
        else fill(255);
        textSize(48);
        text(gameNames[i], width/2, 200 + i * 60);
      }
      textSize(30);
      fill(200);
      text("Use UP/DOWN keys to select, ENTER to start.", width/2, height - 80);
      text("Press Esc to return to the game selection screen.", width/2, height - 40);
    } else if (currentGame != null) {
      currentGame.drawGame();
    }
  }

  void keyPressed() {
    if (inMenu) {
      if (keyCode == UP) {
        selectedIndex = (selectedIndex + gameNames.length - 1) % gameNames.length;
      } else if (keyCode == DOWN) {
        selectedIndex = (selectedIndex + 1) % gameNames.length;
      } else if (key == ENTER || key == RETURN) {
        selectGame(selectedIndex);
      }
    } else if (currentGame != null) {
      currentGame.keyPressed();
    }
  }

  void mousePressed() {
    if (!inMenu && currentGame != null) {
      currentGame.mousePressed();
    }
  }

  void selectGame(int index) {
    inMenu = false;
    if (index == 0) currentGame = new ShootingGame();
    else if (index == 1) currentGame = new AirHockeyGame();
    currentGame.initialize();
  }

  void backToMenu() {
    currentGame = null;
    inMenu = true;
  }
}

// メインスケッチ
GameSelector selector = new GameSelector();
void setup() {
  size(1200, 800);
  textAlign(CENTER, CENTER);
}

void draw() {
  selector.update();
  selector.drawGame();
}

void keyPressed() {
  selector.keyPressed();
  if (!selector.inMenu && key == ESC) {
    selector.backToMenu();
    key = 0;
  }
}

void mousePressed() {
  selector.mousePressed();
}
