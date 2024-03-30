module R = Raylib

type ball = {
  pos : R.Vector2.t;
  speed : R.Vector2.t;
  radius : float;
  color : R.Color.t;
}

type player = {
  pos_x : int;
  pos_y : int;
  width : int;
  height : int;
  color : R.Color.t;
}

type window = {
  width : int;
  height : int;
  margin : int; (* Left/Right margin used to check player limits *)
  background : R.Color.t;
}

type t = {
  pleft : player;
  pright : player;
  ball : ball;
  window : window;
  speed : float;
}
(** structure of State.ml *)

(** [update_player left delta_x delta_y state] update the position of the player
    using [delta_x] and [delta_y]. It will check the boundaries depending he is
    to the left or right of the tennis court. It returns the new state. *)
let update_player (left : bool) dx dy (s : t) =
  let m = s.window.margin in
  let min_x, max_x =
    if left then (m, (s.window.width / 2) - m - s.pleft.width)
    else ((s.window.width / 2) + m, s.window.width - m - s.pright.width)
  in
  let min_y, max_y = (0, s.window.height - s.pleft.height) in
  (* players has the same height *)
  let pos_x, pos_y =
    if left then (s.pleft.pos_x, s.pleft.pos_y)
    else (s.pright.pos_x, s.pright.pos_y)
  in
  let new_x = pos_x + dx in
  let new_y = pos_y + dy in
  (* check boundaries *)
  let new_x =
    if new_x < min_x then min_x else if new_x > max_x then max_x else new_x
  in
  let new_y =
    if new_y < min_y then min_y else if new_y > max_y then max_y else new_y
  in
  (* can now update the player *)
  if left then { s with pleft = { s.pleft with pos_x = new_x; pos_y = new_y } }
  else { s with pright = { s.pright with pos_x = new_x; pos_y = new_y } }

let update_pleft dx dy (s : t) = update_player true dx dy s
let update_pright dx dy (s : t) = update_player false dx dy s

(** [update_ball state] update the position of the ball and return the new state. *)
let update_ball (s : t) =
  let b = s.ball in
  if R.Vector2.x b.speed = 0.0 && R.Vector2.y b.speed = 0.0 then (
    (* we need to follow the left player until he serves *)
    let px = s.pleft.pos_x + s.pleft.width in
    let py = s.pleft.pos_y + (s.pleft.height / 2) in
    R.Vector2.set_x b.pos @@ float_of_int px;
    R.Vector2.set_y b.pos @@ float_of_int py;
    { s with ball = b })
  else s (* update ball when moving *)

(** [update_speed velocity state] add the [velocity] to the state.
    We can not reach a velocity greated than 1000.0 and we can not go below
    a velocity of 10.0 and return the new state *)
let update_speed v (s : t) =
  (* we limite the speed to 1000.0 *)
  let max_speed = 1000.0 in
  let min_speed = 10.0 in
  let new_speed = s.speed +. v in
  {
    s with
    speed =
      (if new_speed > max_speed then max_speed
       else if new_speed < min_speed then min_speed
       else new_speed);
  }
