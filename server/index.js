//IMPORTS

const express = require("express");
const http = require("http");
const mongoose = require("mongoose");
const Game = require("./model/Game");
const getSentence = require("./api/getSentence");
// CREATE A SERVER

const app = express();
const PORT = process.env.PORT || 3000;
var server = http.createServer(app);
var io = require("socket.io")(server);

// MIDDLEWARE // FRONTEND => MIDDLEWARE  => BACKEND

app.use(express.json());

//CONNECT TO MONGODB

const DB = "mongodb+srv://devnidhin:2020@cluster0.tbypu5u.mongodb.net/";

// listeningh to socket io events from the clent

io.on("connection", (socket) => {
  console.log(socket.id);
  socket.on("create-game", async ({ nickname }) => {
    try {
      let game = new Game();
      const sentence = await getSentence();
      game.words = sentence;
      let player = {
        socketID: socket.id,
        nickname,
        isPartyLeader: true,
      };
      game.players.push(player);
      game = await game.save();
      const gameId = game._id.toString();
      socket.join(gameId);
      io.to(gameId).emit("updateGame", game);
    } catch (error) {
      console.log(error);
    }
  });

  socket.on("join-game", async ({ nickname, gameId }) => {
    try {
      if (!gameId.match(/^[0-9a-fA-F]{24}$/)) {
        socket.emit("notCorrectGame", "Please enter a valid game ID");
        return;
      }
      let game = await Game.findById(gameId);

      if (game.isJoin) {
        const id = game._id.toString();
        let player = {
          nickname,
          socketID: socket.id,
        };
        socket.join(id);
        game.players.push(player);
        game = await game.save();
        io.to(gameId).emit("updateGame", game);
      } else {
        socket.emit(
          "notCorrectGame",
          "The game is in progress, please try again later!"
        );
      }
    } catch (e) {
      console.log(e);
    }
  });

  // timer listener
  socket.on("timer", async ({ playerId, gameID }) => {
    let countDown = 5;
    let game = await Game.findById(gameID);
    let player = game.players.id(playerId);

    if (player.isPartyLeader) {
      let timerId = setInterval(async () => {
        if (countDown >= 0) {
          io.to(gameID).emit("timer", {
            countDown,
            msg: "Game Starting",
          });
          console.log(countDown);
          countDown--;
        } else {
          game.isJoin = false;
          game = await game.save();
          io.to(gameID).emit("updateGame", game);
          startGameClock(gameID);
          clearInterval(timerId);
        }
      }, 1000);
    }
  });
});
const startGameClock = async (gameID) => {
  let game = await Game.findById(gameID);
  game.startTime = new Date().getTime();
  game = await game.save();

  let time = 120;

  let timerId = setInterval(
    (function gameIntervalFunc() {
      if (time >= 0) {
        const timeFormat = calculateTime(time);
        io.to(gameID).emit("timer", {
          countDown: timeFormat,
          msg: "Time Remaining",
        });
        console.log(time);
        time--;
      } else {
        (async () => {
          try {
            let endTime = new Date().getTime();
            let game = await Game.findById(gameID);
            let { startTime } = game;
            game.isOver = true;
            game.players.forEach((player, index) => {
              if (player.WPM === -1) {
                game.players[index].WPM = calculateWPM(
                  endTime,
                  startTime,
                  player
                );
              }
            });
            game = await game.save();
            io.to(gameID).emit("updateGame", game);
            clearInterval(timerId);
          } catch (e) {
            console.log(e);
          }
        })();
      }
      return gameIntervalFunc;
    })(),
    1000
  );
};

const calculateTime = (time) => {
  let min = Math.floor(time / 60);
  let sec = time % 60;
  return `${min}:${sec < 10 ? "0" + sec : sec}`;
};

const calculateWPM = (endTime, startTime, player) => {
  const timeTakenInSec = (endTime - startTime) / 1000;
  const timeTaken = timeTakenInSec / 60;
  let wordsTyped = player.currentWordIndex;
  const WPM = Math.floor(wordsTyped / timeTaken);
  return WPM;
};

mongoose
  .connect(DB)
  .then(() => {
    console.log("Connected to sucessfully");
  })
  .catch((e) => {
    console.log(e);
  });

// LISTEN TO SERVER
server.listen(PORT, "0.0.0.0", () => {
  console.log("listening");
});
