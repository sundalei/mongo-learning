db = db.getSiblingDB('tutorial');
db.student.drop();
for(var i = 0; i < 1000000; i++) {
    print('processing student', i);
    var exam_score_value = Math.random() * 100;
    var quiz_score_value = Math.random() * 100;
    var homework_score_value1 = Math.random() * 100;
    var homework_score_value2 = Math.random() * 100;

    var student_id = i;
    var class_id = Math.floor(Math.random() * 200);

    var scores = [];
    var exam_score = {"type": "exam", "score": exam_score_value};
    var quiz_score = {"type": "quiz", "score": quiz_score_value};
    var homework_score1 = {"type": "homework", "quiz": homework_score_value1};
    var homework_score2 = {"type": "homework", "quiz": homework_score_value2};

    scores.push(exam_score);
    scores.push(quiz_score);
    scores.push(homework_score1);
    scores.push(homework_score2);
    db.student.insertOne({"student_id": student_id, "scores": scores, "class_id": class_id});
}