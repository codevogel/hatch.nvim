# Where should we write the GIF?
Output demo.gif 

Set FontSize 16
Set FontFamily "JetbrainsMono Nerd Font Mono"
Set Width 1200
Set Height 600
Set Theme "Kanagawa"
Set WindowBar Colorful

Type "# Welcome to the demo for 🥚 hatch.nvim! 🐦"
Sleep 500ms
Enter 2

Type "# Let's look a template file for .gd (gdscript) files:"
Sleep 500ms
Enter 2

Type "cd ~/.config/hatch.nvim/templates/"
Sleep 500ms
Enter
Type "cat ./default/template.gd"
Sleep 500ms
Enter 2
Sleep 2500ms

Type "# We can create a .gd file and hatch the template:"
Sleep 500ms
Enter 2
Sleep 1500ms

Type "nvim my_script.gd"
Sleep 500ms
Enter
Sleep 1500ms
Type ":Hatch"
Sleep 1000ms
Enter
Sleep 2500ms
Type ":wq"
Sleep 1000ms
Enter
Sleep 500ms
Enter

Type "# It's easy to add new templates. Just create a file named"
Enter
Type "# 'template.{file_extension}' in the template directory."
Enter
Type "# Templates in /custom/ take precedence over /default/."
Enter
Type "# Let's override the .gd template and add a cursor directive"
Sleep 500ms
Enter
Sleep 1500ms

Type "nvim ./custom/template.gd"
Sleep 500ms
Enter
Sleep 1500ms
Type ":Hatch"
Sleep 1000ms
Enter
Type "wcwPlaceholderClass"
Ctrl+c
Sleep 500ms
Type "O#cursor 1:11"
Ctrl+c
Sleep 2500ms
Type ":wq"
Sleep 1000ms
Enter
Sleep 500ms
Enter

Type "# Now, hatching an empty file will insert our new template,"
Enter
Type "# and move the cursor up to the start of PlaceholderClass,"
Enter
Type "# Placing it at the exact spot we want to start changing the file." 
Sleep 500ms
Enter
Sleep 1500ms

Type "nvim my_other_script.gd"
Sleep 500ms
Enter
Sleep 1500ms
Type ":Hatch"
Sleep 1000ms
Enter
Sleep 2000ms
Type "cwSomeOtherClass"
Ctrl+c
Sleep 1000ms
Type ":wq"
Sleep 1000ms
Enter
Sleep 500ms
Enter

Type "# Hatch can also automatically populate empty buffers with"
Enter
Type "# your templates, simply by writing the empty buffer"
Enter
Type "# (This behaviour is on by default, but not shown in the demo.)"
Enter
Sleep 500ms
Type "# You can also override non-empty buffers with :HatchForce"
Sleep 500ms
Enter 2

Type "# Feel free to contribute new templates to the template repository,"
Enter
Type "# or fork it to make it your own!"
Sleep 500ms
Enter 2

Type "# I hope you enjoy hatch.nvim! - codevogel 🐦 (codevogel.com)"
Enter
Sleep 3000ms
