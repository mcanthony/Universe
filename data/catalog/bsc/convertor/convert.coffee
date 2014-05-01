# Require
_ = require 'underscore'
fs = require 'fs'
path = require 'path'
async = require 'async'

#Consts
main_path = './bsc5.dat'
note_path = './notes'

# Usage
printUsage = ->
        console.log "========================================="
        console.log "Bright Star Catalogue Data Convertor"
        console.log "========================================="
        console.log "Dependencies:"
        console.log "\tunderscore"
        console.log "\tcoffee-script"
        console.log "\tasync"
        console.log "Usage:"
        console.log "\tcoffee convert template_file_name output_file_name"
        console.log "Required data files:"
        console.log "\tbsc5.dat\t-\tMain BSC catalogue"
        console.log "\tnotes\t\t-\tBSC notes"
        
# Check arguments
is_coffee = process.argv[0].toLowerCase() == 'coffee'
if process.argv.length < 4
        console.error "Error: invalid arguments"
        printUsage()
        process.exit 1

# Check data file
main_exists = fs.existsSync main_path
note_exists = fs.existsSync note_path

console.log "Main catalogue exists...#{main_exists}"
console.log "Note exists...#{note_exists}"

if not (main_exists and note_exists)
        console.error "Error: could not find BSC data files"
        printUsage()
        process.exit 1

# Check template file
temp_path = "./#{process.argv[2]}"
temp_exists = fs.existsSync temp_path

console.log "Template #{temp_path} exists...#{temp_exists}"

if not temp_exists
        console.error "Error: could not find template file '#{temp_path}'"

# Save path
save_path = "./#{process.argv[3]}"
# TODO: validate path

# Helper
# worker = (line) -> return obj
# callback = (err, data) ->
loadAndParse = (file, worker, callback) ->
        # Load file first
        async.auto
                load: (next) ->
                        fs.readFile file, 'utf8', (err, content) ->
                                if err?
                                        return next? err
                                next? null, content.split '\n'
                parse: ['load', (next, data) ->
                        lines = data.load
                        # Make task
                        tasks = _.map lines, (line) ->
                                return (cb) ->
                                        try
                                                cb null, worker? line
                                        catch err
                                                cb err
                        # Run
                        async.parallel tasks, next
                        ]
                , (err, results) ->
                        if err?
                                return callback err
                        return callback null, results.parse
                  
logBeforeNext = (msg, next) ->
        (err, results) ->
                if err?
                        return next? err
                console.log msg
                next? null, results

t = (line, start, length) ->
        x = line.substr  	start, length
        x.trim()
i = (line, start, length) ->
        parseInt 	t line, start, length
f = (line, start, length) ->
        parseFloat 	t line, start, length
b = (line, pos, true_value) ->
        flag = t line, pos, 1
        flag == true_value
        
parseMainData = (line) ->
        id: 		i line, 0, 	4
        name:		t line, 4,	10
        DM:  		t line, 14,  	11
        HD:  		i line, 25,  	6
        SAO:  		i line, 31,  	6
        FK5:  		i line, 37,  	4
        IS_IR:  	b line, 41,  	'I'
        IR_REF: 	t line, 42,	1
        MULT:		t line, 43,	1
        ADS:		t line, 44,	5
        ADScomp:	t line, 49, 	2
        VAR:		t line, 51,	9
        # Note: we will use J2000.0 only
        RAh:  		i line, 75, 	2
        RAm:  		i line, 77,  	2
        RAs:  		f line, 79,  	4
        DEd:  		i line, 83,  	3
        DEm:  		i line, 86,  	2
        DEs:  		i line, 88,  	2
        GLON: 		f line, 90, 	6
        GLAT: 		f line, 96, 	6
        VMag: 		f line, 102, 	5
        SPEC:  		t line, 127,  	20
        pmRA:  		f line, 148,  	6
        pmDE:  		f line, 152,  	6
        parallax:	f line, 161,	5
        RadVel:		i line, 166,	4
        RotVel:		i line, 176,	3
        DMag:		f line, 180,	4
        Sep:		f line, 184,	6
        MultiID:	t line, 190,	4
        MultiCount:	i line, 194,	2
        HAS_NOTE:	b line, 196,	'*'
        
parseNoteData = (line) ->
        id: 		i line, 1, 4
        category:	t line, 7, 4
        remark:		t line, 12

                        
# Convert work flow
async.auto
        template: (next) ->
                # Open template file
                fs.readFile temp_path,
                        'utf8',
                        logBeforeNext("Template file loaded...", next)
                
        main: (next) ->
                # TODO: parse main catalogue
                loadAndParse main_path,
                        parseMainData,
                        logBeforeNext("Main catalogue loaded...", next)

        note: (next) ->
                # Parse notes
                loadAndParse note_path,
                        parseNoteData,
                        logBeforeNext("Note loaded...", next)
                
        assemble: ['main', 'note', (next, data) ->
                # Assemble main catalogue and notes
                # Sort main data
                asm = _.reduce data.main, ((arr, item) ->
                        #console.log item
                        arr[item.id] = item
                        return arr), []
                # Insert notes
                asm = _.reduce data.note, ((arr, note) ->
                        id = note.id
                        if not arr[id].notes? then arr[id].notes = []
                        arr[id].notes.push note
                        return arr
                        ), asm
                next? null, asm
                console.log "Data assembled..."
                ]
        generate: ['template', 'assemble', (next, data) ->
                # Generate with underscore template
                compiled = _.template data.template, data: data.assemble
                fs.writeFile save_path, compiled, logBeforeNext "File generated..."
                ]
        , (err, results) ->
                if err?
                        console.error "Error: #{err}"
                        process.exit 1


