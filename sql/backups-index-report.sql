SELECT c.id, cc.name, parent.name,
c.shortname, c.fullname,
CONCAT('https://moodle.cca.edu/course/view.php%%Q%%id=', c.id) as shortname_link_url,
GROUP_CONCAT(DISTINCT teachers.fullname SEPARATOR ', ') as instructors,
GROUP_CONCAT(DISTINCT teachers.email SEPARATOR ', ') as instructor_emails,
COUNT(DISTINCT log.id) as hits,
COUNT(DISTINCT cm.id) as modules,
IF(c.visible = 0, "hidden", "visible") as visibility
FROM (
    SELECT ctx.instanceid, u.email, CONCAT(u.firstname, ' ', u.lastname) as fullname
    FROM {context} ctx
    JOIN {role_assignments} ra ON ra.roleid = 3 AND ra.contextid = ctx.id
    JOIN {user} AS u ON ra.userid = u.id
    WHERE ctx.contextlevel = 50
) teachers
JOIN {course} c ON teachers.instanceid = c.id
JOIN {course_categories} cc ON c.category = cc.id
JOIN {course_categories} parent ON cc.parent = parent.id
LEFT JOIN {logstore_standard_log} log ON (c.id = log.courseid AND log.action = 'viewed')
LEFT JOIN {course_modules} cm ON cm.course = c.id
WHERE parent.name = :semester
GROUP BY c.id
ORDER BY c.shortname ASC
